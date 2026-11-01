#!/bin/bash

# Check if git is NOT installed
if ! command -v git &> /dev/null; then
    printf "Error: git is not installed.\n" >&2
    printf "Please install git first and try again.\n" >&2
    exit 1
fi

printf "\n======Global Config Setup======\n"

read -p "Name(Required): " user_name
read -p "Email(Required): " user_email
read -n 1 -p "Select Text Editor? [y]es | No (Default): " t
echo "" # Clean newline after -n 1

CHOSEN_EDITOR=""

case $t in
    y|Y)
        echo "Detecting available editors..."
        EDITORS="code nvim vi vim nano hx helix emacs micro gedit subl"
        INSTALLED_EDITORS=""
        COUNTER=1

        # Loop through and filter out what is actually installed
        for ed in $EDITORS; do
            if command -v "$ed" >/dev/null 2>&1; then
                INSTALLED_EDITORS="$INSTALLED_EDITORS $ed"
            fi
        done

        echo ""
        echo "Available editors found:"
        echo "--------------------------------"

        # Display the menu options
        for ed in $INSTALLED_EDITORS; do
            echo "$COUNTER) $ed"
            COUNTER=$((COUNTER + 1))
        done
        echo "$COUNTER) Custom (Type your own)"
        echo "--------------------------------"

        # Loop until a valid selection is made
        while true; do
            echo ""
            printf "Select an editor by number: "
            read -n 1 choice
            echo "" # Clean newline after -n 1

            # 1. SKIP immediately if the user hits Enter (nothing) or types only spaces
            if [[ -z "$choice" || "$choice" =~ ^[[:space:]]*$ ]]; then
                echo "No selection made. Skipping editor setup."
                break
            fi

            # 2. Check if the input is a valid number
            if ! [[ "$choice" =~ ^[0-9]+$ ]]; then
                echo "Invalid choice. Please pick a number from the menu."
                continue
            fi

            # 3. Check if they selected the "Custom" option
            if [ "$choice" -eq "$COUNTER" ]; then
                printf "Type the name/path of your custom editor: "
                read -r CUSTOM_EDITOR

                if [[ -z "$CUSTOM_EDITOR" || "$CUSTOM_EDITOR" =~ ^[[:space:]]*$ ]]; then
                    echo "No custom path entered. Skipping editor setup."
                    break
                fi
                CHOSEN_EDITOR="$CUSTOM_EDITOR"
                break
            fi

            # 4. Match the number back to the installed list
            CURRENT_INDEX=1
            MATCHFOUND=0
            for ed in $INSTALLED_EDITORS; do
                if [ "$choice" -eq "$CURRENT_INDEX" ]; then
                    CHOSEN_EDITOR="$ed"
                    MATCHFOUND=1
                    break 2
                fi
                CURRENT_INDEX=$((CURRENT_INDEX + 1))
            done

            # 5. If the number was out of range, show invalid message
            if [ "$MATCHFOUND" -eq 0 ]; then
                echo "Invalid choice. Please pick a number from the menu."
            fi
        done

        # Only display confirmation if an editor was actually set
        if [[ -n "$CHOSEN_EDITOR" ]]; then
            echo "--------------------------------"
            echo "You selected: $CHOSEN_EDITOR"
        fi
        ;;
    n|N|"")
        echo "Skipping editor selection."
        ;;
    *)
        echo "Invalid input. Skipping editor selection."
        ;;
esac

echo ""
# Ask the user for final confirmation before performing ANY validation or updates
read -p "Save changes? (y/N): " response

case "${response,,}" in
    y|yes)
        # --- Validate Name (Cannot be empty or just spaces) ---
        if [[ -z "$user_name" || "$user_name" =~ ^[[:space:]]*$ ]]; then
            printf "Error: Name cannot be empty.\n" >&2
            exit 1
        fi

        # --- Validate Email (Cannot be empty or just spaces) ---
        if [[ -z "$user_email" || "$user_email" =~ ^[[:space:]]*$ ]]; then
            printf "Error: Email cannot be empty.\n" >&2
            exit 1
        fi

        # --- Apply Git Configs ---
        git config --global user.name "$user_name"
        git config --global user.email "$user_email"

        # Only sets the core.editor if an editor was actually chosen
        if [[ -n "$CHOSEN_EDITOR" ]]; then
            git config --global core.editor "$CHOSEN_EDITOR"
        fi

        git config --global init.defaultBranch main

        printf "\n======Global Config List======\n"
        git config --global --list
        ;;
    *)
        printf "Cancelled.\n"
        exit 0
        ;;
esac

