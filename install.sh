#!/usr/bin/env bash

set -eu

bye () {
    printf '%s\n' "$1"
    exit 1
}

# Test for a binary in $PATH.
in_path () {
    type -p "$1" >/dev/null
}

# Verbose in_path().
check_for () {
    if ! in_path "$1"; then
        return 1
    fi
}

# install_brew () {
#     echo 'Install Homebrew ..'

#     # https://docs.brew.sh/Installation
#     /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

#     brew update
# }

# ------------

[[ $EUID == 0 ]] || bye 'Run this script with sudo.'

OS=
case $(uname -s) in
    Darwin)
        OS=macos

        pkg_install () {
            sudo -u ${SUDO_USER:-$USER} brew install "$@"
        }
        ;;

    Linux)
        # Test both for magic pathes and supposed package manager
        # binaries.

        if in_path pacman && [[ -f /etc/arch-release ]]; then
            OS=arch

            pkg_install () {
                pacman -S --noconfirm "$@"
            }
        elif in_path apt-get && [[ -f /etc/debian_version ]]; then
            OS=debian

            pkg_install () {
                apt-get --assume-yes install "$@"
            }
        elif in_path dnf && [[ -f /etc/redhat-release ]]; then
            OS=fedora

            pkg_install () {
                dnf --assumeyes install "$@"
            }
        elif in_path zypper; then
            # Quote from https://en.opensuse.org/Etc_SuSE-release:
            #
            # The file /etc/SuSE-release has been marked as
            # depreciated since openSUSE 13.1 and will no longer be
            # present in openSUSE Leap 15.0. Please adjust your
            # software (or file bug reports) to use /etc/os-release
            # instead.
            #
            if [[ -f /etc/SuSE-release ]] || grep -iq opensuse /etc/os-release; then
                OS=suse

                pkg_install () {
                    zypper install --no-confirm "$@"
                }
            fi
        fi
        ;;
esac

[[ -n $OS ]] || bye 'Your OS is not supported.'

clear

cat <<-EOF

Welcome to

    ██████╗  █████╗ ███████╗██╗  ██╗███████╗██╗     ██╗██╗  ██╗
    ██╔══██╗██╔══██╗██╔════╝██║  ██║██╔════╝██║     ██║╚██╗██╔╝
    ██████╔╝███████║███████╗███████║█████╗  ██║     ██║ ╚███╔╝ 
    ██╔══██╗██╔══██║╚════██║██╔══██║██╔══╝  ██║     ██║ ██╔██╗ 
    ██████╔╝██║  ██║███████║██║  ██║██║     ███████╗██║██╔╝ ██╗
    ╚═════╝ ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═╝     ╚══════╝╚═╝╚═╝  ╚═╝

This script will attempt to install the following software:
* python
* pip
* npm
* nodejs
* mpv
* pirate-get
* subliminal
* peerflix

EOF

# Generic tools to packages mapping.
declare -A deps=(
    [curl]=curl
    [pip3]=python3-pip
    [npm]=npm
    [mpv]=mpv
)

MACOS_VLC=/Applications/VLC.app/Contents/MacOS/VLC

# OS-specific overrides for $deps.
case $OS in
    macos)
        deps[pip3]=python       # Provides pip3
        deps[npm]=node          # Provides npm
        deps[$MACOS_VLC]=$MACOS_VLC
        unset -v 'deps[mpv]'
        ;;

    arch)
        deps[pip3]=python-pip
        ;;
esac

# Skip satisfied deps.
for bin in "${!deps[@]}"; do
    if check_for "$bin"; then
        unset -v "deps[$bin]"
    fi
done

# Install unmet deps.
if (( ndeps=${#deps[@]} )); then
    if [[ $OS == macos ]]; then
        #check_for brew || install_brew

        # Special case. https://formulae.brew.sh/cask/mpv
        if [[ -v deps[$MACOS_VLC] ]]; then
            pkg_install --cask mpv
            unset -v 'deps[$MACOS_VLC]'
            ((ndeps--))
        fi
    fi

    (( ndeps )) && pkg_install "${deps[@]}"
fi

# ------------

sudo -u ${SUDO_USER:-$USER} pip3 install --upgrade pirate-get
sudo -u ${SUDO_USER:-$USER} pip3 install --upgrade subliminal
rm -rf /usr/local/lib/node_modules/peerflix
npm uninstall -g peerflix --save
npm install -g peerflix

cd /usr/local/bin
curl -s https://raw.githubusercontent.com/XImport/bashflix/master/bashflix.sh -o bashflix
chmod +x bashflix
touch ~/bashflix_previously.txt

echo 'Bashflix installed and updated!'
bashflix
