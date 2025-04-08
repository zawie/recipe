#!/bin/bash

# Configuration
HTML_DIR="./html"
MARKDOWN_DIR="./markdown"
PORT=8000
HOST="localhost"

# Function to clean up background processes
cleanup() {
  printf "\r🧹 Cleaning up...                                   \n"
  kill "$SERVER_PID" 2>/dev/null
  kill "$WATCHER_PID" 2>/dev/null
  exit 0
}

# Function to serve the HTML directory
serve_html() {
  echo "🌐 Serving files from $HTML_DIR at http://$HOST:$PORT"
  python3 -m http.server "$PORT" --bind "$HOST" --directory "$HTML_DIR" >/dev/null 2>&1 &
  SERVER_PID=$!
}

# Function to watch for changes and rebuild
watch_and_build() {
  printf "👀 Watching $MARKDOWN_DIR for changes...                      "

  # Install fswatch if not present
  if ! command -v fswatch &> /dev/null; then
    echo "⚠️ fswatch not found. Installing via Homebrew..."
    brew install fswatch
  fi

  # Watch for changes and rebuild
  fswatch -o "$MARKDOWN_DIR" | while read -r event; do
    printf "\r🔄 Change detected in markdown files. Rebuilding...      "
    if ./build.sh > /dev/null; then
      printf "\r✅ Build completed successfully                        "
    else
     printf "\r❌ Build failed                                          "
    fi
  done &
  WATCHER_PID=$!
}

# Set up trap for Ctrl+C and other exits
trap cleanup INT TERM EXIT

# Start the services
serve_html
watch_and_build

# Wait indefinitely until interrupted
wait
