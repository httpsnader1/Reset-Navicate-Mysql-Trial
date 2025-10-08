#!/bin/bash
set -euo pipefail

# Author: NakamuraOS <https://github.com/nakamuraos>
# Latest update: 03/19/2025
# Tested with Navicat 15.x, 16.x, and 17.x on Debian and Ubuntu.

BGRED="\e[1;97;41m"
ENDCOLOR="\e[0m"

echo -e "${BGRED}                                            ${ENDCOLOR}"
echo -e "${BGRED}  ┌──────────────────────────────────────┐  ${ENDCOLOR}"
echo -e "${BGRED}  │            !!! WARNING !!!           │  ${ENDCOLOR}"
echo -e "${BGRED}  ├──────────────────────────────────────┤  ${ENDCOLOR}"
echo -e "${BGRED}  │      ALL DATA can be destroyed.      │  ${ENDCOLOR}"
echo -e "${BGRED}  │   Always BACKUP before continuing.   │  ${ENDCOLOR}"
echo -e "${BGRED}  └──────────────────────────────────────┘  ${ENDCOLOR}"
echo -e "${BGRED}                                            ${ENDCOLOR}"

echo -e "Report issues:\n> https://gist.github.com/nakamuraos/717eb99b5e145ed11cd754ad3714b302\n"
echo -e "Reset trial \e[1mNavicat MySQL\e[0m:"

if [[ ! "${1:-}" =~ ^--?[Yy]([eE][sS])?$ ]]; then
    read -p "Are you sure? (y/N) " -r
    echo
    if [[ ! $REPLY =~ ^[Yy]([eE][sS])?$ ]]; then
        echo "Aborted."
        exit 0
    fi
fi

echo "Starting reset..."
DATE=$(date '+%Y%m%d_%H%M%S')

# Backup
echo "=> Creating a backup..."
mkdir -p ~/.config/dconf/user-backup ~/.config/navicat/MySQL/preferences-backup
cp ~/.config/dconf/user ~/.config/dconf/user-backup/user.$DATE
echo "The user dconf backup was created at $HOME/.config/dconf/user-backup/user.$DATE"
cp ~/.config/navicat/MySQL/preferences.json ~/.config/navicat/MySQL/preferences-backup/preferences.json.$DATE
echo "The Navicat preferences backup was created at $HOME/.config/navicat/MySQL/preferences-backup/preferences.json.$DATE"

if ! command -v dconf &>/dev/null; then
    echo "=> dconf is not installed. Installing..."

    if command -v apt-get &>/dev/null; then
        sudo apt-get update
        sudo apt-get install -y dconf-cli
    elif command -v dnf &>/dev/null; then
        sudo dnf install -y dconf
    elif command -v yum &>/dev/null; then
        sudo yum install -y dconf
    elif command -v pacman &>/dev/null; then
        sudo pacman -Sy --noconfirm dconf
    else
        echo "Package manager not supported. Please install dconf manually."
        exit 1
    fi
fi

# Clear data in dconf
echo "=> Resetting..."
dconf reset -f /com/premiumsoft/navicat-mysql/
echo "The user dconf data was reset"

# Remove data fields in config file
sed -i -E 's/,?"([A-F0-9]+)":\{([^\}]+)},?//g' ~/.config/navicat/MySQL/preferences.json
echo "The Navicat preferences was reset"

# Done
echo "Done."

exit 0
