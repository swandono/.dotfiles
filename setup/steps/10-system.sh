#!/usr/bin/env bash
# Essential system steps: base packages, container runtime, Tailscale, Node.
# Sourced by install.sh, never executed. Steps run inside _run_isolated.

# Enable and start a unit, or log why not (containers have no systemd).
_enable_unit() { # UNIT
    local unit=$1
    if ! has_systemd; then
        log_info "skip enabling $unit: no systemd"
        return 0
    fi
    if ! systemctl is-enabled --quiet "$unit" || ! systemctl is-active --quiet "$unit"; then
        systemctl enable --now "$unit"
        mark_changed "enabled $unit"
    fi
}

step_base_packages() {
    apt_install curl wget git unzip zip jq build-essential ca-certificates gnupg xclip xsel
}

step_docker() {
    local arch
    # gnupg is needed to dearmor repo keys.
    apt_install ca-certificates curl gnupg
    arch=$(dpkg --print-architecture)
    apt_add_repo docker https://download.docker.com/linux/ubuntu/gpg \
        "deb [arch=$arch signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu noble stable"
    apt_install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    _enable_unit docker.service
}

step_podman() {
    apt_install podman podman-compose
    _enable_unit podman.socket
}

step_tailscale() {
    apt_install ca-certificates curl gnupg
    apt_add_repo tailscale https://pkgs.tailscale.com/stable/ubuntu/noble.noarmor.gpg \
        "deb [signed-by=/etc/apt/keyrings/tailscale.gpg] https://pkgs.tailscale.com/stable/ubuntu noble main"
    apt_install tailscale
    # Never run `tailscale up`: joining the tailnet is the owner's call.
    _enable_unit tailscaled.service
}

step_node() {
    apt_install ca-certificates curl gnupg
    apt_add_repo nodesource https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key \
        "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_22.x nodistro main"
    apt_install nodejs
}
