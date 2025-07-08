#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

INDEX_FILE="Index.json"
BASE_RAW="https://raw.githubusercontent.com/Its4Nik/DockStacks/refs/heads/main"
BASE_GITHUB="https://github.com/Its4Nik/DockStacks"

# turn on shell-tracing if you want even more (uncomment next line)
# set -x

echo "[DEBUG] Starting create_index_json.sh"
echo "[DEBUG] INDEX_FILE = $INDEX_FILE"
echo "[DEBUG] BASE_RAW    = $BASE_RAW"
echo "[DEBUG] BASE_GITHUB = $BASE_GITHUB"

# Ensure prerequisites
command -v jq >/dev/null 2>&1 || { echo "[ERROR] jq is not installed."; exit 1; }
echo "[DEBUG] jq found"

[[ -d templates ]] || { echo "[ERROR] ./templates directory not found."; exit 1; }
echo "[DEBUG] templates directory exists"

templates=(templates/*)
total=${#templates[@]}
echo "[DEBUG] Found $total entries under ./templates"

if (( total == 0 )); then
  echo "[WARNING] No subdirectories in ./templates to process."
fi

echo "[DEBUG] Generating $INDEX_FILE..."

# start the JSON array
{
  echo "[DEBUG] Writing array start"
  echo "["
  count=0

  for tmpl in "${templates[@]}"; do
    ((count++))
    element=$(basename "$tmpl")
    echo "[DEBUG] --------------------------------------------"
    echo "[DEBUG] Processing #$count/$total => $tmpl"

    if [[ ! -d "$tmpl" ]]; then
      echo "[DEBUG] Skipping $element: not a directory"
      echo "  // Skipping $element (not a directory)"
      continue
    fi

    tpl_json="$tmpl/template.json"
    if [[ ! -f "$tpl_json" ]]; then
      echo "[DEBUG] Skipping $element: no template.json"
      echo "  // Skipping $element (no template.json)"
      continue
    fi

    echo "[DEBUG] Reading $tpl_json"
    name=$(jq -r '.name // empty' "$tpl_json")
    version=$(jq -r '.version // empty' "$tpl_json")
    raw_source=$(jq -r '.source // empty' "$tpl_json")

    echo "[DEBUG] name         = '$name'"
    echo "[DEBUG] version      = '$version'"
    echo "[DEBUG] raw_source   = '$raw_source'"

    [[ -n "$name" ]]    || { echo "[ERROR] .name missing in $tpl_json";    exit 1; }
    [[ -n "$version" ]] || { echo "[ERROR] .version missing in $tpl_json"; exit 1; }

    # icon detection
    icon_file=$(find "$tmpl" -maxdepth 1 -type f \( -iname '*.svg' -o -iname '*.png' \) | head -n1 || true)
    if [[ -n "$icon_file" ]]; then
      icon_url="${BASE_RAW}/templates/${element}/$(basename "$icon_file")"
      echo "[DEBUG] Found icon: '$icon_file' → $icon_url"
    else
      icon_url=""
      echo "[DEBUG] No icon found"
    fi

    # path URL
    path_url="${BASE_RAW}/templates/${element}/template.json"
    echo "[DEBUG] path_url     = $path_url"

    # normalize source
    if [[ "$raw_source" =~ ^https?:// ]]; then
      source_url="$raw_source"
      echo "[DEBUG] source is full URL"
    elif [[ -n "$raw_source" ]]; then
      source_url="${BASE_GITHUB}/${raw_source}"
      echo "[DEBUG] source prefixed → $source_url"
    else
      source_url="$BASE_GITHUB"
      echo "[DEBUG] source defaulted → $source_url"
    fi

    # emit object
    echo "[DEBUG] Emitting JSON object for $element"
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

  echo "[DEBUG] Writing array end"
  echo "]"
} > "$INDEX_FILE"

echo "[DEBUG] DONE — $INDEX_FILE written successfully!"
