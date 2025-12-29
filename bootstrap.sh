#!/usr/bin/env bash

RESET="\033[0m"
BOLD="\033[1m"
ITALIC="\033[3m"
UNDERLINE="\033[4m"
DIM="\033[2m"
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[34m"
PURPLE="\033[35m"
CYAN="\033[36m"
PINK="\033[95m"

if [[ -n "$NO_COLOR" || ! -t 1 ]]; then
    RESET="" BOLD="" ITALIC="" UNDERLINE="" DIM=""
    RED="" GREEN="" YELLOW="" BLUE="" PURPLE="" CYAN=""  PINK=""
fi

p() {
    printf "%b\n" "$1${RESET}"
}

info() {
    p "${BOLD}${BLUE}→ $1"
}

success() {
    p "${BOLD}${GREEN}✔ $1"
}

warning() {
    p "${BOLD}${YELLOW}⚠ $1"
}

error() {
    p "${BOLD}${RED}✖ $1"
}

select_option() {
    local _opts_name=$1
    local question=$2
    local choice
    eval "local _opts=(\"\${${_opts_name}[@]}\")"

    local menu_lines=${#_opts[@]}
    local total_lines=$((menu_lines + 2))

    p "${ITALIC}$question"

    for i in "${!_opts[@]}"; do
        p "${BOLD}${ITALIC}$((i+1)))${RESET} ${_opts[i]}"
    done

    while true; do
        read -rp "Enter choice [1-${menu_lines}]: " choice < /dev/tty
        if [[ "$choice" =~ ^[0-9]+$ ]] && (( choice >= 1 && choice <= menu_lines )); then
            local selected_index=$((choice - 1))
            local selected_value="${_opts[selected_index]}"
            tput cuu "$total_lines"
            for ((i=0; i<total_lines; i++)); do
                tput el
                printf "\n"
            done
            tput cuu "$total_lines"
            p "${ITALIC}${question}${RESET}${GREEN} $selected_value"
            return "$selected_index"
        else
            total_lines=$((total_lines + 2))
            error "Invalid selection. Try again."
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
                error "Please answer yes (y) or no (n)."
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
    p "${BOLD}${prompt}${RESET}"
    for opt in "${options[@]}"; do
        p "    $opt"
    done

    redraw_menu() {
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
        tput cuu "$menu_lines"
        for ((i=0; i<menu_lines; i++)); do
            tput el
            p ""
        done
        tput cuu $((menu_lines + 1))
        tput el
        p "${BOLD}${prompt}${RESET} ${GREEN}${options[selected]}"
        tput cnorm
    }

    abort_ctrl_c() {
        p ""
        tput cnorm
        exit 130
    }

    trap abort_ctrl_c INT
    while true; do
        redraw_menu
        read -rsn1 input < /dev/tty
        case "$input" in
            $'\x1b')
                read -rsn2 input2 < /dev/tty
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

info "${RED}justjcurtis.dev${RESET}${BOLD} setup bootstrap"
info "${PURPLE}https://github.com/justjcurtis/setup"

TMP="$(mktemp -d)"
cd "$TMP" || exit 1

info "Made temporary directory at $TMP"

options=("Burger" "Kebab" "Pizza")
select_option options "Pick a meal:"
jk_arrow_select "Pick a meal:" "${options[@]}"
selected_index=$?

ending=""
if yes_no "Would you like to add fries?" "y"; then
    ending=" with fries"
fi

p "You selected: ${BOLD}${GREEN}${options[selected_index]}${ending}"

