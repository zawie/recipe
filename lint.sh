#!/bin/bash

# Function to display a spinning square animation
show_loading() {
    local pid=$1
    local delay=0.1
    local frames=("⣾" "⣽" "⣻" "⢿" "⡿" "⣟" "⣯" "⣷")

    while kill -0 "$pid" 2>/dev/null; do
        for frame in "${frames[@]}"; do
            printf "\r\033[32m$frame\033[0m Linting"
            sleep "$delay"
        done
    done
}

# Install markdownlint-cli if not already installed
if ! command -v markdownlint > /dev/null 2>&1; then
    echo "markdownlint not found, installing..."
    npm install -g markdownlint-cli &
    show_loading $!  # Show loading animation while installing
    wait $!  # Wait for the installation to complete
fi

# Find all Markdown files (*.md) in the current directory and lint them
# Also try to fix issues automatically with --fix
find . -type f -name "*.md" -exec markdownlint --fix {} --quiet \; &
show_loading $!
wait $!  # Wait for the linting to complete

# Check the result of the markdownlint command
if [ $? -ne 0 ]; then
    printf "\r❌ Linting failed!               \n"
    exit 1
else
    printf "\r✨ Linted!              \n"
fi