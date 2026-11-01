#!/bin/bash

cat << "EOF"
==================================================
           CREDENTIAL ENGINE SELECTOR
==================================================
EOF

width=$(tput cols 2>/dev/null || echo 80)

while IFS= read -r line; do
    printf "%s\n" "$line"
done << 'EOF' | column -t -s ',' -c "$width"
1) Store Engine, - Permanent plain text setup
2) Cache Engine, - Temporary RAM setup
q) Return to Main Menu
EOF
printf "%s\n" "=================================================="

printf "Enter choice (1-2): "
read -r choice

prompt_credentials() {
    printf "Enter GitHub Username: "
    read -r git_user
    printf "Enter Personal Access Token (PAT): "
    read -r git_pat
    
    if [ -z "$git_user" ] || [ -z "$git_pat" ]; then
        printf "Error: Fields cannot be empty.\n" && return 1
    fi
    
    # Force clear any pre-existing global token conflicts to prevent locking bugs
    echo -e "protocol=https\nhost=github.com" | git credential reject 2>/dev/null
    
    # Set the global username identity explicitly so Git maps correctly
    git config --global credential.username "$git_user"
    
    # Approve credentials globally into Git's active credential helper subsystem
    echo -e "protocol=https\nhost=github.com\nusername=$git_user\npassword=$git_pat" | git credential approve
    printf "Global account switched to '%s' and token registered!\n" "$git_user"
}

if [ "$choice" = "1" ]; then
    printf "\n⚠️ WARNING: This saves your token in unencrypted PLAIN TEXT at ~/.git-credentials.\n"
    printf "Do you accept this risk? (y/N): "
    read -r consent
    if [[ "$consent" =~ ^[Yy](es)?$ ]]; then
        git config --global credential.helper store
        prompt_credentials
    else
        printf "Operation canceled.\n"
    fi
elif [ "$choice" = "2" ]; then
    printf "Enter cache timeout in minutes [default: 15]: "
    read -r cache_min
    cache_min=${cache_min:-15}
    git config --global credential.helper "cache --timeout=$((cache_min * 60))"
    prompt_credentials
else
    printf "Returning to master control.\n"
    exit 0
fi

