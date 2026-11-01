#!/bin/bash

while true; do
    cat << "EOF"
==================================================
              GIT TOOLKIT MASTER CONTROL
==================================================
EOF
    printf "1) Configure Identity & Editor  (git-config)\n"
    printf "2) Setup PAT credential         (git-manager)\n"
    printf "3) Manage Token and see details (git-details)\n"
    printf "4) Freeze & Manage Profiles     (git-profiles)\n"
    printf "q) Exit Menu System\n"
    printf "%s\n" "--------------------------------------------------"
    printf "Select an option: "
    read -r master_choice

    case "$master_choice" in
        1) bash "./git-config.sh" ;;
        2) bash "./git-manager.sh" ;;
        3) bash "./git-details.sh" ;;
        4) bash "./git-profiles.sh" ;;
        q|Q) printf "\nExiting.\n"; exit 0 ;;
        *) printf "\nInvalid option.\n" ;;
    esac
    printf "\n"
done

