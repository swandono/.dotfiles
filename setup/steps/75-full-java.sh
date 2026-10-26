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
    pick=$(_java_newest "$vendor" "$major" "$listing")
    if [[ -z $pick ]]; then pick=$(_java_newest temurin "$major" "$listing"); fi
    [[ -n $pick ]] || return 1
    log_warn "mise has no $spec; using $pick instead"
    printf '%s\n' "$pick"
}

# Newest identifier of VENDOR and exact MAJOR in LISTING. Build suffixes such as
# 21.0.7+6.0.LTS are accepted; 210.x is not a 21.
_java_newest() { # VENDOR MAJOR LISTING
    grep -E "^$1-$2(\\.[0-9]+)*(\\+[0-9A-Za-z._+-]*)?\$" <<<"$3" | sort -V | tail -n1 || true
}

_java_runtimes() { # IDENTIFIER...
    _mise_global java "$@"
}

# True when DIR (default: the install) holds the pinned jdtls with the launcher jar.
_java_jdtls_ok() { # [DIR]
    local jd=${1:-$(_jdtls_home)}
    [[ -f $jd/plugins/$JDTLS_LAUNCHER ]] || return 1
    compgen -G "$jd/plugins/org.eclipse.jdt.ls.core_$JDTLS_VERSION.*.jar" >/dev/null
}

# jdtls milestone tarball into ~/.local/share/jdtls. Only the entries that belong to the tarball
# are replaced: workspace/ and lombok.jar are the owner's and stay. The tarball is unpacked into
# a staging dir next to the install and checked there first, so a failed download or extraction
# leaves a working install untouched; the swap is renames only, and the old entries are put back
# if one of them fails.
_java_jdtls() {
    local jd base tmp sha stage e entries=() moved=() ok=1
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
    mkdir -p "$jd" || { rm -rf "$tmp"; return 1; }
    stage=$(mktemp -d "${jd%/*}/.jdtls-stage.XXXXXX") || { rm -rf "$tmp"; return 1; }
    mkdir "$stage/new" "$stage/old" || { rm -rf "$tmp" "$stage"; return 1; }
    # ftplugin/java.lua hardcodes the launcher jar, so a tarball without it is a failure.
    if ! tar -xzf "$tmp/jdtls.tgz" -C "$stage/new" || ! _java_jdtls_ok "$stage/new"; then
        log_warn "the jdtls $JDTLS_VERSION tarball lacks plugins/$JDTLS_LAUNCHER or its core jar"
        rm -rf "$tmp" "$stage"
        return 1
    fi
    rm -rf "$tmp"
    # The tarball's top-level entries, plus the ones older tarballs had, so none of those is left
    # behind from a previous version.
    mapfile -t entries < <({
        find "$stage/new" -mindepth 1 -maxdepth 1 -printf '%f\n'
        printf '%s\n' plugins features config_linux config_linux_arm bin
    } | sort -u)
    for e in "${entries[@]}"; do
        if [[ -e $jd/$e || -L $jd/$e ]]; then
            mv "$jd/$e" "$stage/old/$e" || { ok=0; break; }
        fi
        moved+=("$e")
        if [[ -e $stage/new/$e ]]; then
            mv "$stage/new/$e" "$jd/$e" || { ok=0; break; }
        fi
    done
    if [[ $ok -eq 0 ]]; then
        for e in "${moved[@]}"; do
            rm -rf "${jd:?}/$e"
            if [[ -e $stage/old/$e || -L $stage/old/$e ]]; then mv "$stage/old/$e" "$jd/$e"; fi
        done
        log_warn "replacing jdtls failed; the previous install was put back"
        rm -rf "$stage"
        return 1
    fi
    rm -rf "$stage"
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
