#!/bin/bash

# Configuration storage paths
PROFILE_DIR="$HOME/.git_profiles_vault"
RC_FILE="$HOME/.bashrc" # Change this path to $HOME/.zshrc if you use Zsh!

# Guarantee database directories exist
mkdir -p "$PROFILE_DIR"

cat << "EOF"
==================================================
        GLOBAL GIT PROFILE SWITCHBOARD
==================================================
EOF

printf "1) Save Current Active Setup as Profile\n"
printf "2) List Existing Profiles\n"
printf "3) Clear Git to Blank Slate\n"
printf "4) Return to Main Menu\n"
printf "%s\n" "--------------------------------------------------"
printf "Enter choice (1-4): "
read -r prof_choice

if [ "$prof_choice" = "1" ]; then
    printf "\nEnter a short name for this profile (e.g., work, personal): "
    read -r prof_name
    
    # Strip dangerous characters to make a clean name
    prof_name=$(echo "$prof_name" | tr '[:upper:]' '[:lower:]' | tr -cd '[:alnum:]')
    
    if [ -z "$prof_name" ]; then
        printf "Invalid profile name string. Aborting.\n"
        exit 1
    fi

    # Define frozen asset target locations
    target_config="$PROFILE_DIR/gitconfig-$prof_name"
    target_credentials="$PROFILE_DIR/credentials-$prof_name"

    # 1. Take a text copy snapshot of your active configuration matrix
    if [ -f "$HOME/.gitconfig" ]; then
        cp "$HOME/.gitconfig" "$target_config"
    else
        touch "$target_config"
    fi

    # 2. Extract and preserve standalone store files if present
    if [ -f "$HOME/.git-credentials" ]; then
        cp "$HOME/.git-credentials" "$target_credentials"
    else
        rm -f "$target_credentials"
    fi

    # 3. Generate the absolute automated fast-switch shell shortcut string
    alias_cmd="alias git-$prof_name='cp $target_config \$HOME/.gitconfig; [ -f $target_credentials ] && cp $target_credentials \$HOME/.git-credentials || rm -f \$HOME/.git-credentials; printf \"Switched globally to profile: %s\\\n\" \"$prof_name\"'"
    
    # Clean out any old matching lines inside your system shell files to prevent duplicates
    if [ -f "$RC_FILE" ]; then
        grep -v "alias git-$prof_name=" "$RC_FILE" > "${RC_FILE}.tmp" && mv "${RC_FILE}.tmp" "$RC_FILE"
        echo "$alias_cmd" >> "$RC_FILE"
        printf "Profile saved successfully! Automation alias injected.\n"
        printf "👉 Please run: source %s\n" "$RC_FILE"
        printf "👉 Then use: git-%s anywhere to shift your whole system setup!\n" "$prof_name"
    else
        printf "Profile saved, but system profile target path was missing. Alias skipped.\n"
    fi

elif [ "$prof_choice" = "2" ]; then
    printf "\n--- Available Saved Profiles ---\n"
    if [ -d "$PROFILE_DIR" ] && [ "$(ls -A "$PROFILE_DIR" 2>/dev/null)" ]; then
        for f in "$PROFILE_DIR"/gitconfig-*; do
            [ -e "$f" ] || continue
            p_name=$(basename "$f" | sed 's/gitconfig-//')
            p_user=$(git config -f "$f" credential.username)
            p_email=$(git config -f "$f" user.email)
            p_helper=$(git config -f "$f" credential.helper)
            printf "🔹 Alias: git-%s | User: %s | Email: %s | Backend: %s\n" "$p_name" "${p_user:-Unset}" "${p_email:-Unset}" "${p_helper:-Unset}"
        done
    else
        printf "No profiles discovered in your profile storage vault yet.\n"
    fi

elif [ "$prof_choice" = "3" ]; then
    printf "\n⚠️ This completely wipes your current active git state globally.\n"
    printf "Do you want to reset your environment to a clean blank slate? (y/N): "
    read -r clean_consent
    if [[ "$clean_consent" =~ ^[Yy](es)?$ ]]; then
        # Force terminate active pipeline keys out of system RAM helpers
        echo -e "protocol=https\nhost=github.com" | git credential reject 2>/dev/null
        # Wipe the file targets entirely
        rm -f "$HOME/.gitconfig"
        rm -f "$HOME/.git-credentials"
        printf "Clean blank slate applied. Current runtime identities and tokens have been wiped.\n"
    else
        printf "Wipe sequence aborted.\n"
    fi
else
    printf "Returning to master control menu.\n"
    exit 0
fi

