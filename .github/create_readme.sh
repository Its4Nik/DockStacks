
cat ./.github/DockStacks_README.md > README.md

{
    echo "| Icon | Name | Schema |"
    echo "|------|------|--------|"
} >> README.md

for element in $(ls ./templates); do
    # 1. Icon
    # 2. Name
    # 3. Schema
    path="./templates/${element}"
    icon="$(ls "${path}" | grep ".svg" | tr -d '[:space:]')"
    name="$(cat "${path}/template.json" | jq ".name")"

    if [[ -z $icon ]]; then
        icon="None"
    else
        icon="${path}/${icon}"
        icon="![$element]($icon)"
    fi

    echo "|$icon|$name|[$path](${path}/template.json)" >> README.md
done
