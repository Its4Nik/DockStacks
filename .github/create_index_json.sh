#!/usr/bin/env bash
set -euo pipefail

# base for raw-content URLs
BASE_RAW="https://raw.githubusercontent.com/Its4Nik/DockStacks/refs/heads/main"
# fallback GitHub repo-url for "source" fields that aren't already full URLs
BASE_GITHUB="https://github.com/Its4Nik/DockStacks"

INDEX_FILE="Index.json"
templates=(templates/*)
total=${#templates[@]}
count=0

# start array
printf '[\n' > "$INDEX_FILE"

for tmpl in "${templates[@]}"; do
  ((count++))
  element=$(basename "$tmpl")

  # pick the first SVG or PNG in the folder, if any
  icon_file=$(find "$tmpl" -maxdepth 1 -type f \( -iname '*.svg' -o -iname '*.png' \) | head -n1 || true)
  if [[ -n "$icon_file" ]]; then
    icon_url="${BASE_RAW}/templates/${element}/$(basename "$icon_file")"
  else
    icon_url=""
  fi

  # always point to the raw template.json
  path_url="${BASE_RAW}/templates/${element}/template.json"

  # read name, version, source from the template.json
  name=$(jq -r '.name' "$tmpl/template.json")
  version=$(jq -r '.version' "$tmpl/template.json")
  raw_source=$(jq -r '.source // empty' "$tmpl/template.json")

  # normalize source: if it’s already an http(s) URL, keep it; otherwise prefix with BASE_GITHUB
  if [[ "$raw_source" =~ ^https?:// ]]; then
    source_url="$raw_source"
  elif [[ -n "$raw_source" ]]; then
    # e.g. if template.json had "Its4Nik/DockStacks" or just "" 
    source_url="${BASE_GITHUB}/${raw_source}"
  else
    source_url="$BASE_GITHUB"
  fi

  # build the object
  cat <<EOF >> "$INDEX_FILE"
  {
    "name": "$name",
    "icon": "$icon_url",
    "path": "$path_url",
    "version": "$version",
    "source": "$source_url"
  }$( [[ $count -lt $total ]] && echo "," )
EOF

done

# close array
printf ']\n' >> "$INDEX_FILE"

echo "DONE"
