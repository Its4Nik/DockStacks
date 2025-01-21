import os
import markdown
from markdown.extensions.codehilite import CodeHiliteExtension
from markdown.extensions.fenced_code import FencedCodeExtension

def convert_md_to_html_in_templates():
    """
    Converts README.md files in each subdirectory of ./src/templates
    to HTML and saves them as README.html in the same folder.
    Supports syntax highlighting for code blocks.
    """
    base_path = "./src/templates"

    if not os.path.exists(base_path):
        print(f"Directory does not exist: {base_path}")
        return

    for folder_name in os.listdir(base_path):
        folder_path = os.path.join(base_path, folder_name)

        if os.path.isdir(folder_path):
            md_path = os.path.join(folder_path, "README.md")
            html_path = os.path.join(folder_path, "README.html")

            if os.path.exists(md_path):
                try:
                    with open(md_path, "r", encoding="utf-8") as md_file:
                        md_content = md_file.read()

                    html_content = markdown.markdown(
                        md_content,
                        extensions=[
                            FencedCodeExtension(),
                            CodeHiliteExtension(noclasses=False),
                        ],
                    )

                    with open(html_path, "w", encoding="utf-8") as html_file:
                        html_file.write(html_content)

                    print(f"Converted: {md_path} -> {html_path}")
                except Exception as e:
                    print(f"Error processing {md_path}: {e}")
            else:
                print(f"No README.md found in: {folder_path}")

if __name__ == "__main__":
    convert_md_to_html_in_templates()
