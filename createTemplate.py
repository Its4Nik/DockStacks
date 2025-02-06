import os
import json

template_dir = "./src/templates"
templates = [
    folder for folder in os.listdir(template_dir)
    if "schema.json" in os.listdir(os.path.join(template_dir, folder))
]

with open("./src/static/templates.json", "w") as file:
    json.dump(templates, file, indent=2)
