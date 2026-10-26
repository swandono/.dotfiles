#!/usr/bin/env bash
# Full profile: Java for jdtls. JDKs through mise (mise_bin, _mise and _mise_global come from
# 70-full-lang.sh), jdtls, lombok and java-debug under ~/.local/share, which is where
# ftplugin/java.lua looks. Sourced by install.sh, never executed. Steps run inside
# _run_isolated, so no EXIT traps here.

_jdtls_home() { printf '%s\n' "$HOME/.local/share/jdtls"; }

# Print the mise identifier to install for the wanted SPEC (vendor-MAJOR.MINOR.PATCH).
# The exact identifier is used when it is installed or listed by mise. Otherwise the newest
# version of the same major and vendor is used, and when mise has no such vendor at all, the
# newest temurin of that major. Every fallback is a warning: record it in the commit body.
_java_pick() { # SPEC
    local spec=$1 vendor major listing pick
    vendor=${spec%%-*}
    major=${spec#*-}
    major=${major%%.*}
    if _mise_global_has java "$spec"; then
        printf '%s\n' "$spec"
        return 0
    fi
    listing=$(_mise ls-remote java 2>/dev/null) || return 1
    if grep -qxF "$spec" <<<"$listing"; then
        printf '%s\n' "$spec"
        return 0
    fi
    pick=$(grep -E "^$vendor-$major\\.[0-9.]+\$" <<<"$listing" | sort -V | tail -n1 || true)
    if [[ -z $pick ]]; then
        pick=$(grep -E "^temurin-$major\\.[0-9.]+\$" <<<"$listing" | sort -V | tail -n1 || true)
    fi
    [[ -n $pick ]] || return 1
    log_warn "mise has no $spec; using $pick instead"
    printf '%s\n' "$pick"
}

_java_runtimes() { # IDENTIFIER...
    _mise_global java "$@"
}

_java_jdtls_ok() {
    local jd
    jd=$(_jdtls_home)
    [[ -f $jd/plugins/$JDTLS_LAUNCHER ]] || return 1
    compgen -G "$jd/plugins/org.eclipse.jdt.ls.core_$JDTLS_VERSION.*.jar" >/dev/null
}

# jdtls milestone tarball into ~/.local/share/jdtls. Only the directories that belong to the
# tarball are replaced: workspace/ and lombok.jar are the owner's and stay.
_java_jdtls() {
    local jd base tmp sha d
    jd=$(_jdtls_home)
    _java_jdtls_ok && return 0
    base=https://download.eclipse.org/jdtls/milestones/$JDTLS_VERSION
    sha=$(sha256_from_sums "$base/$JDTLS_TARBALL.sha256" "$JDTLS_TARBALL" 2>/dev/null || true)
    if [[ -z $sha ]]; then
        # The .sha256 file may hold the bare hash only.
        sha=$(curl -fsSL "$base/$JDTLS_TARBALL.sha256" | awk '{ print $1; exit }') || return 1
    fi
    [[ $sha =~ ^[0-9a-f]{64}$ ]] || { log_warn "no sha256 for $JDTLS_TARBALL"; return 1; }
    tmp=$(mktemp -d)
    fetch "$base/$JDTLS_TARBALL" "$tmp/jdtls.tgz" "$sha" || { rm -rf "$tmp"; return 1; }
    mkdir -p "$tmp/x"
    tar -xzf "$tmp/jdtls.tgz" -C "$tmp/x" || { rm -rf "$tmp"; return 1; }
    mkdir -p "$jd"
    for d in plugins features config_linux config_linux_arm bin; do rm -rf "${jd:?}/$d"; done
    cp -a "$tmp/x/." "$jd/" || { rm -rf "$tmp"; return 1; }
    rm -rf "$tmp"
    # ftplugin/java.lua hardcodes this launcher jar, so a tarball without it is a failure.
    [[ -f $jd/plugins/$JDTLS_LAUNCHER ]] || { log_warn "jdtls $JDTLS_VERSION has no plugins/$JDTLS_LAUNCHER"; return 1; }
    mark_changed "installed jdtls $JDTLS_VERSION"
}

_java_lombok() {
    local dest
    dest=$(_jdtls_home)/lombok.jar
    if [[ -f $dest && $(sha256sum "$dest" | cut -d' ' -f1) == "$LOMBOK_SHA256" ]]; then
        return 0
    fi
    fetch "https://repo1.maven.org/maven2/org/projectlombok/lombok/$LOMBOK_VERSION/lombok-$LOMBOK_VERSION.jar" \
        "$dest" "$LOMBOK_SHA256" || return 1
    mark_changed "installed lombok $LOMBOK_VERSION"
}

# java-debug from its pinned tag commit, built with the Java 21 that mise installed.
_java_debug() { # JAVA21_IDENTIFIER
    local id=$1 dir=$HOME/.local/share/java-debug
    local jar=$dir/com.microsoft.java.debug.plugin/target/com.microsoft.java.debug.plugin-$JAVA_DEBUG_VERSION.jar
    [[ -f $jar ]] && return 0
    mkdir -p "$dir"
    git_pin https://github.com/microsoft/java-debug.git "$dir" "$JAVA_DEBUG_SHA"
    (cd "$dir" && _mise exec "java@$id" -- ./mvnw clean install -DskipTests) || return 1
    [[ -f $jar ]] || { log_warn "java-debug build produced no $jar"; return 1; }
    mark_changed "built java-debug $JAVA_DEBUG_VERSION"
}

step_java() {
    # shellcheck disable=SC2206  # the pin is a space separated list
    local specs=($MISE_JAVA) ids=() spec id id21=""
    apt_install openjdk-17-jdk-headless maven curl ca-certificates git unzip tar
    for spec in "${specs[@]}"; do
        if id=$(_java_pick "$spec"); then
            ids+=("$id")
            [[ $id == *-21.* ]] && id21=$id
        else
            log_warn "no mise java matches $spec"
        fi
    done
    if [[ ${#ids[@]} -gt 0 ]]; then try_tool mise-java _java_runtimes "${ids[@]}"; fi
    try_tool jdtls _java_jdtls
    try_tool lombok _java_lombok
    if [[ -n $id21 ]]; then
        try_tool java-debug _java_debug "$id21"
    else
        BOOTSTRAP_FAILED+=("java-debug")
        log_warn "no java 21 from mise, java-debug cannot be built"
    fi
}
