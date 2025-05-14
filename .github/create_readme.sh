
cat ./.github/DockStacks_README.md > README.md

{
    echo -e "\n## Available Stacks\n"
    echo "| Icon | Name | Schema |"
    echo "|------|------|--------|"
} >> README.md

for element in $(ls ./templates); do
    # 1. Icon
    # 2. Name
    # 3. Schema
    path="./templates/${element}"
    icon="$(ls "${path}" | grep ".svg\|.png" | tr -d '[:space:]')"
    name="$(cat "${path}/template.json" | jq ".name" | tr -d '"')"

    if [[ -z $icon ]]; then
        icon="/"
    else
        icon="${path}/${icon}"
        icon="<img src=\"$icon\" alt=\"$element\" width=\"50\" height=\"50\">"
    fi

    echo "|$icon|$name|[$name](${path}/template.json)" >> README.md
done

cat "./.github/README_footer.md" >> README.md
