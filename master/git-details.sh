#!/bin/bash

printf "\n==================================================\n"
printf "               CURRENT SETUP DETAILS              \n"
printf "==================================================\n"

current_helper=$(git config --global credential.helper)
current_user=$(git config --global credential.username)

if [ -z "$current_helper" ]; then
    printf "Status: No global helper configured.\n"
else
    printf "Status: Configured\n"
    printf "Active Helper: %s\n" "$current_helper"
fi

[ -n "$current_user" ] && printf "Configured Username: %s\n" "$current_user"
printf "%s\n" "--------------------------------------------------"

store_file="$HOME/.git-credentials"
if [ -f "$store_file" ]; then
    printf "⚠️ ALERT: Text credential file found at: %s\n" "$store_file"
    printf "%s\n" "--------------------------------------------------"
fi

printf "Checking active runtime vault for github.com...\n"
cred_output=$(echo -e "protocol=https\nhost=github.com" | GIT_TERMINAL_PROMPT=0 git credential fill 2>/dev/null)
detected_user=$(echo "$cred_output" | grep "username=" | cut -d= -f2-)
detected_pat=$(echo "$cred_output" | grep "password=" | cut -d= -f2-)

if [ -n "$detected_user" ]; then
    printf "Active Token Username: %s\n" "$detected_user"
    printf "Active Token (PAT): %s\n" "$detected_pat"
else
    printf "No active runtime token discovered.\n"
fi
printf "==================================================\n\n"

printf "Sub-Options Menu:\n"
printf "1) Disconnect & Unset Credentials\n"
printf "2) Return\n"
printf "Enter choice (1-2): "
read -r detail_choice

if [ "$detail_choice" = "1" ]; then
    # Wipe the active runtime memory token cache
    echo -e "protocol=https\nhost=github.com" | git credential reject 2>/dev/null
    # Clear out global config variables
    git config --global --unset-all credential.helper 2>/dev/null
    git config --global --unset-all credential.username 2>/dev/null
    printf "\nSuccessfully disconnected active tokens and unset global configurations!\n"
    
    if [ -f "$store_file" ]; then
        printf "Delete the plain text file (~/.git-credentials) too? (y/N): "
        read -r del_file
        [[ "$del_file" =~ ^[Yy](es)?$ ]] && rm -f "$store_file" && printf "Storage file deleted.\n"
    fi
else
    exit 0
fi

