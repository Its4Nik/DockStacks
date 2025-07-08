#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

INDEX_FILE="Index.json"
BASE_RAW="https://raw.githubusercontent.com/Its4Nik/DockStacks/refs/heads/main"
BASE_GITHUB="https://github.com/Its4Nik/DockStacks"

# turn on shell-tracing if you want even more (uncomment next line)
# set -x

log() {
  echo "[DEBUG] $*"
}

error() {
  echo "[ERROR] $*" >&2
  exit 1
}

log "Starting create_index_json.sh"
log "INDEX_FILE = $INDEX_FILE"
log "BASE_RAW    = $BASE_RAW"
log "BASE_GITHUB = $BASE_GITHUB"

# Ensure prerequisites
command -v jq >/dev/null 2>&1 || error "jq is not installed."
log "jq found"

[[ -d templates ]] || error "./templates directory not found."
log "templates directory exists"

templates=(templates/*)
total=${#templates[@]}
log "Found $total entries under ./templates"

if (( total == 0 )); then
  echo "[WARNING] No subdirectories in ./templates to process."
fi

log "Generating $INDEX_FILE..."

# Create a temporary file for the JSON output
temp_file=$(mktemp)
trap 'rm -f "$temp_file"' EXIT

log "Writing array start"
echo "[" > "$temp_file"
count=0
processed=0

for tmpl in "${templates[@]}"; do
  let "count = count + 1"
  element=$(basename "$tmpl")
  log "--------------------------------------------"
  log "Processing #$count/$total => $tmpl"

  if [[ ! -d "$tmpl" ]]; then
    log "Skipping $element: not a directory"
    continue
  fi

  tpl_json="$tmpl/template.json"
  if [[ ! -f "$tpl_json" ]]; then
    log "Skipping $element: no template.json"
    continue
  fi

  log "Reading $tpl_json"
  name=$(jq -r '.name // empty' "$tpl_json")
  version=$(jq -r '.version // empty' "$tpl_json")
  raw_source=$(jq -r '.source // empty' "$tpl_json")

  log "name         = '$name'"
  log "version      = '$version'"
  log "raw_source   = '$raw_source'"

  [[ -n "$name" ]]    || error ".name missing in $tpl_json"
  [[ -n "$version" ]] || error ".version missing in $tpl_json"

  # icon detection
  icon_file=$(find "$tmpl" -maxdepth 1 -type f \( -iname '*.svg' -o -iname '*.png' \) | head -n1 || true)
  if [[ -n "$icon_file" ]]; then
    icon_url="${BASE_RAW}/templates/${element}/$(basename "$icon_file")"
    log "Found icon: '$icon_file' → $icon_url"
  else
    icon_url=""
    log "No icon found"
  fi

  # path URL
  path_url="${BASE_RAW}/templates/${element}/template.json"
  log "path_url     = $path_url"

  # normalize source
  if [[ "$raw_source" =~ ^https?:// ]]; then
    source_url="$raw_source"
    log "source is full URL"
  elif [[ -n "$raw_source" ]]; then
    source_url="${BASE_GITHUB}/${raw_source}"
    log "source prefixed → $source_url"
  else
    source_url="$BASE_GITHUB"
    log "source defaulted → $source_url"
  fi

  # Add comma if not the first processed entry
  (( processed > 0 )) && echo -n "," >> "$temp_file"

  # emit object
  log "Emitting JSON object for $element"
  jq -n \
    --arg name "$name" \
    --arg icon "$icon_url" \
    --arg path "$path_url" \
    --arg version "$version" \
    --arg source "$source_url" \
    '{
      name: $name,
      icon: $icon,
      path: $path,
      version: $version,
      source: $source
    }' >> "$temp_file"

  let "processed = processed + 1"
done

log "Writing array end"
echo "]" >> "$temp_file"

# Validate the JSON before moving to final location
if jq empty "$temp_file" >/dev/null 2>&1; then
  jq . "$temp_file" > "$INDEX_FILE"
  log "DONE — $INDEX_FILE written successfully with $processed entries!"
else
  error "Generated JSON is invalid. Aborting."
fi
