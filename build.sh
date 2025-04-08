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

urlencode() {
  local input_file="$1"
  local encoded_content=""

  while IFS= read -r line || [[ -n "$line" ]]; do
    # URL encode each line and append to the content
    # The newline characters are encoded as %0A (URL encoded)
    encoded_content+=$(echo -n "$line" | xxd -p -c 1000 | tr -d '\n' | sed 's/\(..\)/%\1/g')
    # Preserve the newline by appending %0A after encoding each line
    encoded_content+='%0A'
  done < "$input_file"

  # Return the encoded content
  echo "$encoded_content"
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
    --metadata=filename:"$(basename -- $file)" \
    --metadata=samplecontent:"$MARKDOWN_SAMPLE_CONTENT" \

  echo "Built: $output"
done
