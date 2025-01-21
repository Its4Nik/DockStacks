# Contributing to DockStacks

Thank you for considering contributing to the DockStacks! Contributions are welcome and greatly appreciated. Follow these guidelines to help us maintain a well-organized and efficient project.

---

## Table of Contents
1. [How to Contribute](#how-to-contribute)
2. [Reporting Issues](#reporting-issues)
3. [Suggesting Features](#suggesting-features)
4. [Submitting Templates](#submitting-templates)

---

## How to Contribute

1. **Fork the Repository**:
   - Fork this repository to your GitHub account.
   - Clone the forked repository to your local machine.

2. **Create a New Branch**:
   - Name your branch descriptively, e.g., `add-new-template` or `fix-bug-in-grid`.
   - Example:
     ```bash
     git checkout -b add-my-template
     ```

3. **Make Your Changes**:
   - Ensure all new templates follow the folder structure:
     ```txt
     template/{STACK_NAME}/
       ├── schema.json
       ├── README.md
       └── DESCRIPTION.md
     ```
   - Validate JSON schema files using online or CLI JSON schema validators (IDE integration works best for me!).

4. **Test Your Changes**:
   - Verify that your changes work as expected locally.
   - Check the appearance of the grid and modal (if applicable).

5. **Commit Your Changes**:
   - Write clear and concise commit messages.
   - Example:
     ```bash
     git commit -m "Add template for Redis stack"
     ```

6. **Push and Submit a Pull Request**:
   - Push your changes to your fork:
     ```bash
     git push origin add-my-template
     ```
   - Open a pull request (PR) from your branch to the `main` branch of this repository.

---

## Reporting Issues

- Use the [GitHub Issues](https://github.com/its4nik/dockstacks/issues) page to report bugs or suggest improvements.
- Provide a clear and detailed description:
  - Steps to reproduce (if a bug).
  - Expected behavior and actual behavior.
  - Screenshots (if applicable).

---

## Suggesting Features

- Before suggesting a new feature, check if a similar suggestion already exists in the [Issues](https://github.com/its4nik/dockstacks/issues).
- If not, open a new issue and provide:
  - A detailed explanation of the feature.
  - A brief example or use case.

---

## Submitting Templates

When submitting a new template:
1. Create a new folder in the `template/` directory named after the stack (e.g., `redis`, `nginx`).
2. Add the required files:
   - **`schema.json`**: Follows the repository’s JSON schema format.
   - **`README.md`**: Describes the stack, its use, and configuration options.
   - **`DESCRIPTION.md`**: A short description for the stack (max 50 characters).
3. Ensure your files are formatted correctly:
   - Validate `schema.json` using a JSON schema validator.
   - Ensure `README.md` is clear, concise, and well-structured.

---

## Need Help?

Feel free to ask questions or seek help in the [Discussions](https://github.com/its4nik/dockstacks/discussions) section.
