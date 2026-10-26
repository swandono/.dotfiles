#!/usr/bin/env bash
# Full profile: ops tools, network and security packages, Google Chrome. Sourced by install.sh,
# never executed. Steps run inside _run_isolated, so no EXIT traps here: every temp dir is
# removed explicitly on each exit path. Needs 20-cli.sh (_cli_has_version) as well.
#
# Verification per download (versions.env has the details):
#   AWS CLI v2          PGP signature against setup/keys/aws-cli.asc, fingerprint checked
#   session-manager     sha256 pinned in versions.env
#   aws-vault           release SHA256SUMS
#   mkcert              sha256 pinned in versions.env

_OPS_SETUP_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)
_AWS_CLI_KEY_FPR=FB5DB77FD5C118B80511ADA8A6310ACC4672475C

# Verify FILE against the detached signature SIG with the committed AWS CLI key. Only a good
# signature made by exactly that fingerprint counts.
_ops_verify_awscli() { # FILE SIG
    local gh status rc=0
    gh=$(mktemp -d)
    chmod 700 "$gh"
    GNUPGHOME=$gh gpg --batch --quiet --import "$_OPS_SETUP_DIR/keys/aws-cli.asc" >/dev/null 2>&1 || rc=1
    if [[ $rc -eq 0 ]]; then
        status=$(GNUPGHOME=$gh gpg --batch --status-fd 1 --verify "$2" "$1" 2>/dev/null) || rc=1
        [[ $status == *"VALIDSIG $_AWS_CLI_KEY_FPR "* ]] || rc=1
    fi
    rm -rf "$gh"
    [[ $rc -eq 0 ]] || log_warn "PGP verification of ${1##*/} failed"
    return "$rc"
}

_ops_install_awscli() {
    local arch asset url tmp
    if _cli_has_version aws "aws-cli/$AWSCLI_VERSION"; then return 0; fi
    arch=$(bootstrap_arch)
    asset=awscli-exe-linux-$arch-$AWSCLI_VERSION.zip
    url=https://awscli.amazonaws.com/$asset
    tmp=$(mktemp -d)
    fetch "$url" "$tmp/$asset" || { rm -rf "$tmp"; return 1; }
    fetch "$url.sig" "$tmp/$asset.sig" || { rm -rf "$tmp"; return 1; }
    _ops_verify_awscli "$tmp/$asset" "$tmp/$asset.sig" || { rm -rf "$tmp"; return 1; }
    unzip -q "$tmp/$asset" -d "$tmp/x" || { rm -rf "$tmp"; return 1; }
    "$tmp/x/aws/install" --update -i /usr/local/aws-cli -b /usr/local/bin >/dev/null || { rm -rf "$tmp"; return 1; }
    rm -rf "$tmp"
    mark_changed "installed aws-cli $AWSCLI_VERSION"
}

_ops_install_ssm() {
    local arch dir sha tmp
    # The package version carries a packaging suffix (1.2.835.0-1).
    # shellcheck disable=SC2016  # dpkg-query format string
    if [[ $(dpkg-query -W -f='${Version}' session-manager-plugin 2>/dev/null || true) == "$SSM_PLUGIN_VERSION"-* ]]; then
        return 0
    fi
    arch=$(bootstrap_arch)
    if [[ $arch == aarch64 ]]; then
        dir=ubuntu_arm64
        sha=$SSM_PLUGIN_SHA256_AARCH64
    else
        dir=ubuntu_64bit
        sha=$SSM_PLUGIN_SHA256_X86_64
    fi
    tmp=$(mktemp -d)
    fetch "https://s3.amazonaws.com/session-manager-downloads/plugin/$SSM_PLUGIN_VERSION/$dir/session-manager-plugin.deb" \
        "$tmp/ssm.deb" "$sha" || { rm -rf "$tmp"; return 1; }
    DEBIAN_FRONTEND=noninteractive dpkg -i "$tmp/ssm.deb" >/dev/null || { rm -rf "$tmp"; return 1; }
    rm -rf "$tmp"
    mark_changed "installed session-manager-plugin $SSM_PLUGIN_VERSION"
}

_ops_install_aws_vault() {
    local arch asset base sha tmp
    if _cli_has_version aws-vault "v$AWS_VAULT_VERSION"; then return 0; fi
    arch=amd64
    [[ $(bootstrap_arch) == aarch64 ]] && arch=arm64
    asset=aws-vault-linux-$arch
    base=https://github.com/99designs/aws-vault/releases/download/v$AWS_VAULT_VERSION
    sha=$(sha256_from_sums "$base/SHA256SUMS" "$asset") || return 1
    tmp=$(mktemp -d)
    fetch "$base/$asset" "$tmp/$asset" "$sha" || { rm -rf "$tmp"; return 1; }
    install_bin "$tmp/$asset" aws-vault || { rm -rf "$tmp"; return 1; }
    rm -rf "$tmp"
}

_ops_install_mkcert() {
    local arch sha tmp
    if _cli_has_version mkcert "v$MKCERT_VERSION"; then return 0; fi
    arch=amd64
    sha=$MKCERT_SHA256_X86_64
    if [[ $(bootstrap_arch) == aarch64 ]]; then
        arch=arm64
        sha=$MKCERT_SHA256_AARCH64
    fi
    tmp=$(mktemp -d)
    fetch "https://github.com/FiloSottile/mkcert/releases/download/v$MKCERT_VERSION/mkcert-v$MKCERT_VERSION-linux-$arch" \
        "$tmp/mkcert" "$sha" || { rm -rf "$tmp"; return 1; }
    install_bin "$tmp/mkcert" mkcert || { rm -rf "$tmp"; return 1; }
    rm -rf "$tmp"
}

step_ops() {
    apt_install curl ca-certificates unzip gnupg
    try_tool awscli _ops_install_awscli
    try_tool session-manager-plugin _ops_install_ssm
    try_tool aws-vault _ops_install_aws_vault
    try_tool mkcert _ops_install_mkcert
    try_tool ops-apt apt_install rclone postgresql-client redis-tools
    warn_shadowed aws /usr/local/bin/aws
    warn_shadowed aws-vault /usr/local/bin/aws-vault
    warn_shadowed mkcert /usr/local/bin/mkcert
}

step_net_sec() {
    # --no-install-recommends keeps postfix (a recommendation of several of these) and its prompts out.
    try_tool net-sec-apt _net_sec_apt
}

_net_sec_apt() {
    local pkg status missing=()
    for pkg in openvpn wireguard clamav clamav-freshclam rkhunter lynis; do
        # shellcheck disable=SC2016  # dpkg-query format string
        status=$(dpkg-query -W -f='${Status}' "$pkg" 2>/dev/null || true)
        [[ $status == "install ok installed" ]] || missing+=("$pkg")
    done
    [[ ${#missing[@]} -gt 0 ]] || return 0
    DEBIAN_FRONTEND=noninteractive apt-get update -qq "${APT_LOCK_OPTS[@]}" || return 1
    DEBIAN_FRONTEND=noninteractive apt-get install -y -qq --no-install-recommends "${APT_LOCK_OPTS[@]}" \
        -o Dpkg::Options::=--force-confold "${missing[@]}" || return 1
    mark_changed "apt installed ${missing[*]}"
}

# Chrome manages its own apt source: its postinst and cron job write
# /etc/apt/sources.list.d/google-chrome.sources (deb822) with the key at
# /usr/share/keyrings/google-chrome.gpg, migrate a legacy google-chrome.list into it and rewrite
# both whenever they like. A second source of the same repo (an apt_add_repo list under any name)
# would be a duplicate-source warning or a file that flips on every run. So the bootstrap only
# seeds that same file and key once, in Chrome's own format, to make the first install possible,
# and once google-chrome-stable is installed the repo is Chrome's and is never touched again.
_browser_seed_repo() {
    local tmp
    tmp=$(mktemp -d)
    fetch https://dl.google.com/linux/linux_signing_key.pub "$tmp/key" || { rm -rf "$tmp"; return 1; }
    gpg --batch --yes --dearmor -o "$tmp/key.gpg" "$tmp/key" || { rm -rf "$tmp"; return 1; }
    cat >"$tmp/sources" <<'EOF'
X-Repolib-Name: Google Chrome
Types: deb
URIs: https://dl.google.com/linux/chrome-stable/deb/
Suites: stable
Components: main
Architectures: amd64
Signed-By: /usr/share/keyrings/google-chrome.gpg
EOF
    install -d -m 0755 /usr/share/keyrings /etc/apt/sources.list.d || { rm -rf "$tmp"; return 1; }
    install -m 0644 "$tmp/key.gpg" /usr/share/keyrings/google-chrome.gpg || { rm -rf "$tmp"; return 1; }
    install -m 0644 "$tmp/sources" /etc/apt/sources.list.d/google-chrome.sources || { rm -rf "$tmp"; return 1; }
    rm -rf "$tmp"
    _APT_UPDATED=0
}

_browser_chrome() {
    local status
    # shellcheck disable=SC2016  # dpkg-query format string
    status=$(dpkg-query -W -f='${Status}' google-chrome-stable 2>/dev/null || true)
    if [[ $status != "install ok installed" ]]; then
        _browser_seed_repo || return 1
    fi
    apt_install google-chrome-stable
}

step_browser() {
    # Only Chrome lacks an aarch64 build; xvfb and the fonts install everywhere.
    if [[ $(bootstrap_arch) == aarch64 ]]; then
        log_warn "Google Chrome has no aarch64 build; skipping chrome"
        BOOTSTRAP_SKIPPED+=("chrome")
    else
        try_tool chrome _browser_chrome
    fi
    try_tool browser-apt apt_install xvfb fonts-liberation fonts-noto-color-emoji fonts-ipafont-gothic \
        fonts-wqy-zenhei fonts-tlwg-loma-otf fonts-freefont-ttf fonts-unifont xfonts-cyrillic xfonts-scalable
}
