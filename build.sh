#!/bin/bash
# build.sh - Convert all Markdown files in ./markdown to HTML in ./html using pandoc

get_title() {
    local file="$1"
    sed -n 's/<!--title:\(.*\)-->/\1/p' "$file"
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
    if [[ "$html_filename" == "index.html" ]]; then
        continue
    fi
    echo "- [$(get_title "$file")](/$html_filename)" >> "$WORKING_DIR/index.md"
done

for file in "$WORKING_DIR"/*.md; do
  output="$OUTPUT_DIR/$(get_html_file_name "$file")"

  title=$(get_title $file)

  pandoc "$file" \
    -o "$output" \
    --standalone \
    --template="$TEMPLATE" \
    --metadata=title:"$title" \

  echo "Built: $output"
done
