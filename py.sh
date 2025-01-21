#!/bin/bash

python3 -m venv ./

echo "
./lib*
./bin
./include
" > .gitignore

source ./bin/activate

pip install -r ./requirements.txt

./bin/python3 ./build.py

node ./src/createTemplate.js


if [[ ! "$CI" = "true" ]]; then
    python3 -m http.server 8080 -d ./src/
fi
