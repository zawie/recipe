#!/bin/bash
# build.sh - Convert all Markdown files in ./markdown to HTML in ./html using pandoc

set -e

INPUT_DIR="markdown"
OUTPUT_DIR="html"
TEMPLATE="template.html"

mkdir -p "$OUTPUT_DIR"

for file in "$INPUT_DIR"/*.md; do
  filename=$(basename -- "$file" .md)
  output="$OUTPUT_DIR/$filename.html"

  title=$(sed -n 's/<!--title:\(.*\)-->/\1/p' $file)

  pandoc "$file" \
    -o "$output" \
    --standalone \
    --template="$TEMPLATE" \
    --metadata=title:"$title" \

  echo "Built: $output"
done
