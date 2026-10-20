#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
config_home="${XDG_CONFIG_HOME:-$HOME/.config}"
target_dir="$config_home/fastfetch"
fish_hook="$config_home/fish/conf.d/spinning-arch-logo.fish"
marker_start="# >>> spinning-arch-logo >>>"
marker_end="# <<< spinning-arch-logo <<<"

autostart=true
uninstall=false

usage() {
    cat <<EOF
Usage: ./install.sh [--no-autostart] [--uninstall]

  --no-autostart   don't run fastfetch every time a terminal opens
  --uninstall      remove everything this script added
EOF
}

for argument in "$@"; do
    case "$argument" in
        --no-autostart) autostart=false ;;
        --uninstall) uninstall=true ;;
        -h|--help) usage; exit 0 ;;
        *) echo "Unknown option: $argument" >&2; usage >&2; exit 1 ;;
    esac
done

remove_block() {
    local rc_file="$1"
    [ -f "$rc_file" ] || return 0
    sed -i "/^$marker_start\$/,/^$marker_end\$/d" "$rc_file"
}

posix_rc_files() {
    local login_shell
    login_shell="$(basename "${SHELL:-}")"
    if [ -f "$HOME/.bashrc" ] || [ "$login_shell" = "bash" ]; then
        echo "$HOME/.bashrc"
    fi
    if [ -f "$HOME/.zshrc" ] || [ "$login_shell" = "zsh" ]; then
        echo "$HOME/.zshrc"
    fi
}

if [ "$uninstall" = true ]; then
    rm -f "$target_dir/spinning_logo.py" "$target_dir/spin.wav"
    rm -f "$fish_hook"
    while read -r rc_file; do
        remove_block "$rc_file"
    done < <(posix_rc_files)
    echo "Removed. Open a new terminal and fastfetch is back to normal."
    exit 0
fi

missing_packages=()
command -v fastfetch >/dev/null || missing_packages+=(fastfetch)
command -v python3 >/dev/null || missing_packages+=(python)
command -v pw-play >/dev/null || missing_packages+=(pipewire)

if [ "${#missing_packages[@]}" -gt 0 ]; then
    if command -v pacman >/dev/null; then
        echo "Installing ${missing_packages[*]}..."
        sudo pacman -S --needed --noconfirm "${missing_packages[@]}"
    elif ! command -v fastfetch >/dev/null || ! command -v python3 >/dev/null; then
        echo "Please install fastfetch and python3 with your package manager, then run this again." >&2
        exit 1
    fi
fi

mkdir -p "$target_dir"
install -m 755 "$repo_dir/spinning_logo.py" "$target_dir/spinning_logo.py"
install -m 644 "$repo_dir/spin.wav" "$target_dir/spin.wav"

if command -v fish >/dev/null; then
    mkdir -p "$(dirname "$fish_hook")"
    {
        echo "status is-interactive; or return"
        echo
        echo "function fastfetch"
        echo "    if test (count \$argv) -eq 0; and isatty stdout"
        echo "        python3 \"$target_dir/spinning_logo.py\" (command fastfetch --pipe false --logo none | string collect) 2>/dev/null"
        echo "        or command fastfetch"
        echo "    else"
        echo "        command fastfetch \$argv"
        echo "    end"
        echo "end"
        if [ "$autostart" = true ]; then
            echo
            echo "fastfetch"
        fi
    } > "$fish_hook"
    echo "Added the fish hook: $fish_hook"
fi

while read -r rc_file; do
    remove_block "$rc_file"
    {
        echo "$marker_start"
        echo "fastfetch() {"
        echo "    if [ \"\$#\" -eq 0 ] && [ -t 1 ]; then"
        echo "        python3 \"$target_dir/spinning_logo.py\" \"\$(command fastfetch --pipe false --logo none)\" 2>/dev/null || command fastfetch"
        echo "    else"
        echo "        command fastfetch \"\$@\""
        echo "    fi"
        echo "}"
        if [ "$autostart" = true ]; then
            echo "case \$- in *i*) fastfetch ;; esac"
        fi
        echo "$marker_end"
    } >> "$rc_file"
    echo "Added the hook to $rc_file"
    if grep -qxE '[[:space:]]*fastfetch[[:space:]]*' <(sed "/^$marker_start\$/,/^$marker_end\$/d" "$rc_file"); then
        echo "  Heads up: $rc_file already runs fastfetch somewhere else, so you might see it twice. Delete that line if so."
    fi
done < <(posix_rc_files)

echo
echo "Done! Open a new terminal (or just type fastfetch) and watch it spin."
