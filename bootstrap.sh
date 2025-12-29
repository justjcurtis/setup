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

jk_arrow_select() {
    local prompt="$1"
    shift
    local options=("$@")
    local selected=0
    local menu_lines=${#options[@]}

    tput civis

    # Print prompt
    p "${BOLD}${prompt}${RESET}"

    # Initial menu
    for opt in "${options[@]}"; do
        p "    $opt"
    done

    redraw_menu() {
        # Move to top of menu
        tput cuu "$menu_lines"

        for i in "${!options[@]}"; do
            tput el
            if (( i == selected )); then
                p "  ${GREEN}> ${options[i]}${RESET}"
            else
                p "    ${options[i]}"
            fi
        done
    }

    finish_select() {
        # Move to top of menu
        tput cuu "$menu_lines"

        # Clear menu
        for ((i=0; i<menu_lines; i++)); do
            tput el
            printf "\n"
        done

        # Move to prompt line
        tput cuu $((menu_lines + 1))
        tput el

        # Rewrite prompt with selection
        p "${BOLD}${prompt}${RESET} ${GREEN}${options[selected]}"

        tput cnorm
    }

    abort_ctrl_c() {
        # Move cursor below menu, leave everything intact
        printf "\n"
        tput cnorm
        exit 130
    }

    trap abort_ctrl_c INT

    while true; do
        redraw_menu

        read -rsn1 input < /dev/tty
        case "$input" in
            $'\x1b')
                read -rsn2 -t 0.1 input2 < /dev/tty
                input+="$input2"
                ;;
        esac

        case "$input" in
            j|$'\x1b[B')
                ((selected++))
                ((selected >= menu_lines)) && selected=0
                ;;
            k|$'\x1b[A')
                ((selected--))
                ((selected < 0)) && selected=$((menu_lines - 1))
                ;;
            "")
                finish_select
                trap - INT
                return "$selected"
                ;;
        esac
    done
}

cleanup() {
    if [[ -n "$TMP" && -d "$TMP" ]]; then
        rm -rf "$TMP"
        tput cnorm
        exit 0
    fi
}

trap cleanup EXIT INT TERM

p "→ ${BOLD}${RED}justjcurtis.dev${RESET}${BOLD} setup bootstrap"
p "→ ${PURPLE}https://github.com/justjcurtis/setup"

TMP="$(mktemp -d)"
cd "$TMP" || exit 1

p "→ Made temporary directory at $TMP"

options=("Burger" "Kebab" "Pizza")
# select_option options "Pick a meal:"
# selected_index=$?
jk_arrow_select "Pick a meal:" "${options[@]}"
selected_index=$?

ending=""
if yes_no "Would you like to add fries?" "y"; then
    ending=" with fries"
fi

p "You selected value: ${options[selected_index]}${ending}"

