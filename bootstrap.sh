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
    printf "$1${RESET}\n" 
}

select_option() {
    local -n _opts=$1
    local question=$2
    local choice

    p "${ITALIC}$question" 
    for i in "${!_opts[@]}"; do
        printf "${BOLD}${ITALIC}%d)${RESET} %s\n" $((i + 1)) "${_opts[i]}"
    done

    while true; do
        read -rp "Enter choice [1-${#_opts[@]}]: " choice

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
    if [[ "$default_answer" == "y" ]]; then
        brackets="[Y/n]"
    elif [[ "$default_answer" == "n" ]]; then
        brackets="[y/N]"
    fi

    while true; do
        read -rp "$question $brackets: " response
        case "$response" in
            [Yy]* ) return 0 ;;
            [Nn]* ) return 1 ;;
            * )
                if [[ -n "$default_answer" ]]; then
                    if [[ "$default_answer" == "y" ]]; then
                        return 0
                    else
                        return 1
                    fi
                else
                    printf "Please answer yes or no.\n"
                fi
                ;;
        esac
    done
}


p "→ ${BOLD}${RED}justjcurtis.dev${RESET}${BOLD} setup bootstrap"
p "→ ${PURPLE}https://github.com/justjcurtis/setup"


TMP="$(mktemp -d)"
cd "$TMP"

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
rm -rf "$TMP\n"
p "→ Removed temporary directory"

