# Contributing

## Creating a template

### Foreword

Thanks for having interest in this project!
Adding your favorite stacks / setups should be really easy to do, since YAML is fully JSON compliant.

### Guide

1. Create the basis directory
  - Create a directory in [./templates](./templates)
  - Name this folder just like your application (_Only lower letters and dashes / underscores please_)
2. Create a template.json file
  - Please follow [this](#Cheatsheet) cheatsheet on how to add your stack.
3. (Optional) Add a icon file
  - Upload a SVG Icon
  - Fallback: DockStat Icon

### Cheatsheet

```jsonc
{
  "name": "nginx-simple",         // Name for this stack
  "version": 1,                   // Revision
  "custom": false,                // will be handled by the backend
  "source": "internal",           // The source (eg: https://github.com/Its4Nik/DockStacks)
  "compose_spec": {               // Docker compose yaml as JSON structure
    "services": {
      "web": {
        "image": "nginx:latest",
        "ports": [
          "80:80"
        ]
      }
    }
  }
}
```
