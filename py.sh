#!/bin/bash

if [[ ! "$CI" = "true" ]]; then
    python="./bin/python3"
    pip="./bin/pip"
else
    python="python3"
    pip="pip"
fi

echo "
./lib*
./bin
./include
" > .gitignore

if [[ ! "$CI" = "true" ]]; then
    python3 -m venv ./

    source ./bin/activate
fi

$pip install -r ./requirements.txt

$python ./build.py

$python ./src/createTemplate.py


if [[ ! "$CI" = "true" ]]; then
    $python -m http.server 8080 -d ./src/
fi

echo "
./lib*
./bin
./include
" > .gitignore
