#!/bin/bash
# Shared logic for path_oracle

log_info() { echo -e "\x1b[32m\u2713\x1b[0m $1"; }
log_warn() { echo -e "\x1b[33m\u2614\x1b[0m $1"; }
log_error() { echo -e "\x1b[31mError:\x1b[0m $1"; exit 1; }
log_step() { echo -e "\n\x1b[36m$1\x1b[0m"; }

verify_path() {
    local target_path="$1"
    if [ -z "$target_path" ]; then log_error "Missing target_path."; fi
    if [ ! -d "$target_path" ]; then log_error "Path $target_path not found."; fi
    echo "$(realpath "$target_path")"
}

check_version() {
    local target_path="$1"
    local expected_regex="$2"
    if [ -f "$target_path/package.json" ]; then
        # Use python for version extraction to avoid node complexity
        local version=$(python3 -c "import json; print(json.load(open('$target_path/package.json')).get('version', 'unknown'))")
        echo "  - version: $version"
        if [[ ! $version =~ $expected_regex ]]; then
            log_warn "This patch is tested for $expected_regex. Proceeding with caution..."
        else log_info "Version compatible."; fi
    else log_error "package.json not found in $target_path"; fi
}

safe_reset() {
    local target_path="$1"
    shift
    local files=("$@")
    if [ -d "$target_path/.git" ]; then
        log_info "Safe-Reset: Restoring target files to origin state..."
        git -C "$target_path" checkout "${files[@]}" 2>/dev/null
        log_info "Baseline is clean."
    else log_warn "Target is not a git repo. Skipping Safe-Reset."; fi
}
