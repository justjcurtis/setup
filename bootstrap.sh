#!/usr/bin/env bash

RESET="\033[0m"
BOLD="\033[1m"
ITALIC="\033[3m"
UNDERLINE="\033[4m"
RED="\033[31m"
BLUE="\033[34m"
GREEN="\033[32m"
YELLOW="\033[33m"
CYAN="\033[36m"
PURPLE="\033[35m"
PINK="\033[95m"

p() {
    printf "%b\n" "$1${RESET}"
}

select_option() {
    local _opts_name=$1
    local question=$2
    local choice
    eval "local _opts=(\"\${${_opts_name}[@]}\")"

    p "${ITALIC}$question"
    for i in "${!_opts[@]}"; do
        printf "${BOLD}${ITALIC}%d)${RESET} %s\n" $((i + 1)) "${_opts[i]}"
    done

    while true; do
        read -rp "Enter choice [1-${#_opts[@]}]: " choice < /dev/tty
        if [[ "$choice" =~ ^[0-9]+$ ]] && (( choice >= 1 && choice <= ${#_opts[@]} )); then
            return $((choice - 1))
        else
            printf "Invalid selection. Try again.\n"
        fi
    done
}

yes_no() {
    local question=$1
    local default_answer=$2
    local response

    local brackets="[y/n]"
    [[ "$default_answer" == "y" ]] && brackets="[Y/n]"
    [[ "$default_answer" == "n" ]] && brackets="[y/N]"

    while true; do
        read -rp "$question $brackets: " response < /dev/tty
        case "$response" in
            [Yy]* ) return 0 ;;
            [Nn]* ) return 1 ;;
            "" )
                [[ "$default_answer" == "y" ]] && return 0
                [[ "$default_answer" == "n" ]] && return 1
                ;;
            * )
                printf "Please answer yes or no.\n"
                ;;
        esac
    done
}

p "→ ${BOLD}${RED}justjcurtis.dev${RESET}${BOLD} setup bootstrap"
p "→ ${PURPLE}https://github.com/justjcurtis/setup"

TMP="$(mktemp -d)"
cd "$TMP" || exit 1

p "→ Made temporary directory at $TMP"

options=("Burger" "Kebab" "Pizza")
select_option options "Pick a meal:"
selected_index=$?

ending=""
if yes_no "Would you like to add fries?" "y"; then
    ending=" with fries"
fi

p "You selected value: ${options[selected_index]}${ending}"

p "→ Cleaning up..."
rm -rf "$TMP"
p "→ Removed temporary directory"

