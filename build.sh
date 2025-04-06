#!/bin/bash
# build.sh - Convert all Markdown files in ./markdown to HTML in ./html using pandoc

get_attribute() {
    local file="$1"
    local attribute="$2"
    sed -n "s/<!--$attribute:\(.*\)-->/\1/p" "$file"
}

get_html_file_name() {
    local file="$1"
    filename=$(basename -- "$file" .md)

    echo "$filename.html"
}

set -e

INPUT_DIR="markdown"
WORKING_DIR="working"
OUTPUT_DIR="html"
TEMPLATE="template.html"

mkdir -p "$WORKING_DIR"
cp -r "$INPUT_DIR"/* "$WORKING_DIR"

mkdir -p "$OUTPUT_DIR"

for file in "$WORKING_DIR"/*.md; do
    html_filename=$(get_html_file_name "$file")
    if [[ $(get_attribute "$file" "list") == "false" ]]; then
        continue
    fi
    echo "- [$(get_attribute "$file" "title")](/$html_filename)" >> "$WORKING_DIR/index.md"
done

for file in "$WORKING_DIR"/*.md; do
  output="$OUTPUT_DIR/$(get_html_file_name "$file")"

  title=$(get_attribute "$file" "title")

  pandoc "$file" \
    -o "$output" \
    --standalone \
    --template="$TEMPLATE" \
    --metadata=title:"$title" \

  echo "Built: $output"
done
