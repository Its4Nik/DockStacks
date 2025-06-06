#!/bin/bash

all_count="$(ls templates | wc -l)"
count=0

echo "[" > Index.json

for element in $(ls ./templates); do
    let "count = count + 1"
    icon="templates/${element}/$(ls "./templates/${element}" | grep ".svg\|.png" | tr -d '[:space:]')"
    data="$(cat ./templates/${element}/template.json)"
    name="$(echo "$data" | jq '.name')"
    version="$(echo "$data" | jq '.version')"
    source="$(echo "$data" | jq '.source')"

    if [[ $count -eq $all_count ]]; then
        echo -e "\
\t{
\t\t\"name\": ${name},
\t\t\"icon\": \"${icon}\",
\t\t\"path\": \"templates/${element}/template.json\",
\t\t\"version\": \"${version}\",
\t\t\"source\": ${source}
\t}" >> Index.json
    else
        echo -e "\
\t{
\t\t\"name\": ${name},
\t\t\"icon\": \"${icon}\",
\t\t\"path\": \"templates/${element}/template.json\",
\t\t\"version\": \"${version}\",
\t\t\"source\": ${source}
\t}," >> Index.json
    fi
done


echo "]" >> Index.json

echo "DONE"
