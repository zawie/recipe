#!/bin/sh

# Install markdownlint-cli if not already installed
if ! command -v markdownlint > /dev/null 2>&1
then
    echo "markdownlint not found, installing..."
    npm install -g markdownlint-cli
fi

# Find all Markdown files (*.md) in the current directory and lint them
# Also try to fix issues automatically with --fix
find . -type f -name "*.md" -exec markdownlint --fix {} \;

# Check the result of the markdownlint command
if [ $? -ne 0 ]; then
    echo "Linting errors found and could not be fixed."
    exit 1
else
    echo "All Markdown files passed linting and were fixed!"
fi
