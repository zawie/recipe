#!/bin/sh
# build.sh - Convert all Markdown files in ./markdown to HTML in ./html using pandoc

get_attribute() {
    file="$1"
    attribute="$2"
    sed -n "s/<!--$attribute:\(.*\)-->/\1/p" "$file"
}

get_html_file_name() {
    file="$1"
    filename=$(basename -- "$file" .md)
    echo "$filename.html"
}

urlencode() {
    input_file="$1"
    encoded_content=""

    while IFS= read -r line || [ -n "$line" ]; do
        # Encode each byte to %XX
        encoded_line=$(printf '%s' "$line" | od -An -tx1 | tr -s ' ' '\n' | grep -v '^$' | sed 's/^/%/' | tr -d '\n')
        encoded_content="${encoded_content}${encoded_line}%0A"
    done < "$input_file"

    # Remove the final newline encoding if needed
    echo "${encoded_content%\\%0A}"
}

set -e

INPUT_DIR="markdown"
WORKING_DIR="/tmp/working"
OUTPUT_DIR="html"
TEMPLATE="template.html"
MARKDOWN_SAMPLE_CONTENT=$(urlencode template.md)

mkdir -p "$WORKING_DIR"
cp -r "$INPUT_DIR"/* "$WORKING_DIR"

mkdir -p "$OUTPUT_DIR"

for file in "$WORKING_DIR"/*.md; do
    html_filename=$(get_html_file_name "$file")
    list_value=$(get_attribute "$file" "list")
    if [ "$list_value" = "false" ]; then
        continue
    fi
    title=$(get_attribute "$file" "title")
    echo "- [$title](/$html_filename)" >> "$WORKING_DIR/index.md"
done

for file in "$WORKING_DIR"/*.md; do
    output="$OUTPUT_DIR/$(get_html_file_name "$file")"
    title=$(get_attribute "$file" "title")

    pandoc "$file" \
        -o "$output" \
        --standalone \
        --template="$TEMPLATE" \
        --metadata=title:"$title" \
        --metadata=filename:"$(basename -- "$file")" \
        --metadata=samplecontent:"$MARKDOWN_SAMPLE_CONTENT"

    echo "Built: $output"
done
