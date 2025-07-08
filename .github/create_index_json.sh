#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

INDEX_FILE="Index.json"
BASE_RAW="https://raw.githubusercontent.com/Its4Nik/DockStacks/refs/heads/main"
BASE_GITHUB="https://github.com/Its4Nik/DockStacks"

# Ensure prerequisites
command -v jq >/dev/null 2>&1 || { echo >&2 "Error: jq is not installed."; exit 1; }
[[ -d templates ]] || { echo >&2 "Error: ./templates directory not found."; exit 1; }

templates=(templates/*)
total=${#templates[@]}
if (( total == 0 )); then
  echo >&2 "Warning: no subdirectories in ./templates to process."
fi

echo "> Generating $INDEX_FILE from $total template(s)..."

# start the JSON array
{
  echo "["
  count=0

  for tmpl in "${templates[@]}"; do
    ((count++))
    element=$(basename "$tmpl")

    [[ -d "$tmpl" ]] || {
      echo "  // Skipping $tmpl (not a directory)"
      continue
    }

    # locate template.json
    tpl_json="$tmpl/template.json"
    if [[ ! -f "$tpl_json" ]]; then
      echo "  // Skipping $element (no template.json)"
      continue
    fi

    # pick first SVG/PNG if any
    icon_file=$(find "$tmpl" -maxdepth 1 -type f \( -iname '*.svg' -o -iname '*.png' \) | head -n1 || true)
    if [[ -n "$icon_file" ]]; then
      icon_url="${BASE_RAW}/templates/${element}/$(basename "$icon_file")"
    else
      icon_url=""
    fi

    # always point to the raw template.json
    path_url="${BASE_RAW}/templates/${element}/template.json"

    # read fields
    name=$(jq -r '.name // empty' "$tpl_json")
    version=$(jq -r '.version // empty' "$tpl_json")
    raw_source=$(jq -r '.source // empty' "$tpl_json")

    # sanity checks
    [[ -n "$name" ]] || { echo >&2 "Error: '.name' is missing in $tpl_json"; exit 1; }
    [[ -n "$version" ]] || { echo >&2 "Error: '.version' is missing in $tpl_json"; exit 1; }

    # normalize source
    if [[ "$raw_source" =~ ^https?:// ]]; then
      source_url="$raw_source"
    elif [[ -n "$raw_source" ]]; then
      source_url="${BASE_GITHUB}/${raw_source}"
    else
      source_url="$BASE_GITHUB"
    fi

    # emit object
    cat <<EOF
  {
    "name": "$name",
    "icon": "$icon_url",
    "path": "$path_url",
    "version": "$version",
    "source": "$source_url"
  }$( [[ $count -lt $total ]] && echo "," )
EOF

  done

  echo "]"
} > "$INDEX_FILE"

echo "✔ $INDEX_FILE written successfully."
