#!/bin/bash

python3 -m venv ./

source ./bin/activate

./bin/python3 ./build.py

node ./src/createTemplate.js

pip install -r ./requirements.txt

python3 -m http.server 8080 -d ./src/
