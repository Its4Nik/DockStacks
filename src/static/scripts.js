document.addEventListener("DOMContentLoaded", async () => {
  const gridContainer = document.getElementById("grid-container");
  const modal = document.getElementById("modal");
  const modalBody = document.getElementById("modal-body");
  const closeModal = document.getElementById("close-modal");

  // Add the converter button dynamically
  const converterButton = document.createElement("button");
  converterButton.id = "open-converter";
  converterButton.className = "converter-btn";
  converterButton.textContent = "YAML to JSON Converter";
  document.body.insertBefore(converterButton, gridContainer);

  const templates = await fetch("./static/templates.json").then((res) =>
    res.json(),
  );

  templates.forEach((template) => {
    const bubble = document.createElement("div");
    bubble.className = "bubble";
    bubble.innerHTML = `
            <div>
            <p><h2>${template}</h2></p>
            <div>
            <p id="image-${template}">Loading Logo...</p>
            <p id="description-${template}">Loading description...</p>
            </div>
            </div>
        `;
    bubble.addEventListener("click", () => openModal(template));
    gridContainer.appendChild(bubble);

    fetch(`./templates/${template}/DESCRIPTION.md`)
      .then((res) => res.text())
      .then((description) => {
        const converter = new showdown.Converter();
        const htmlDescription = converter.makeHtml(
          description.length > 50
            ? `${description.slice(0, 47)}...`
            : description,
        );
        document.getElementById(`description-${template}`).innerHTML =
          htmlDescription;
      });

    fetch(`./templates/${template}/logo.png`)
      .then((response) => {
        if (response.ok) {
          return response.blob();
        } else {
          throw new Error("Image not found");
        }
      })
      .then((blob) => {
        const imgUrl = URL.createObjectURL(blob);
        document.getElementById(`image-${template}`).innerHTML = `
          <img src="${imgUrl}" />
        `;
      })
      .catch(() => {
        document.getElementById(`image-${template}`).innerHTML = `
          <div></div>
        `;
      });
  });

  async function openModal(template) {
    let readme = await fetch(`./templates/${template}/README.md`).then((res) =>
      res.text(),
    );

    const converter = new showdown.Converter({
      tables: true,
      simplifiedAutoLink: true,
      literalMidWordUnderscores: true,
      ghCodeBlocks: true,
    });

    const htmlContent = converter.makeHtml(readme);

    modalBody.innerHTML = `
      <div id="markdown-content">
        ${htmlContent}
      </div>
      <p><a href="./templates/${template}/schema.json" target="_blank">View Raw Schema</a></p>
    `;

    Prism.highlightAll();
    modal.style.display = "flex";
  }

  converterButton.addEventListener("click", () => {
    modalBody.innerHTML = `
      <h1>YAML to JSON Converter</h1>
      <textarea id="yaml-input" placeholder="Paste your YAML here..."></textarea>
      <br>
      <button id="convert-btn" class="converter-btn">Convert</button>
      <button id="copy-btn" class="converter-btn">Copy</button>
      <pre id="json-output"></pre>
    `;
    document
      .getElementById("convert-btn")
      .addEventListener("click", convertYamlToJson);
    document
      .getElementById("copy-btn")
      .addEventListener("click", copyJSONContent);
    modal.style.display = "flex";
  });

  closeModal.addEventListener("click", () => {
    modal.style.display = "none";
  });

  window.addEventListener("click", (event) => {
    if (event.target === modal) {
      modal.style.display = "none";
    }
  });

  function extractEnvVars(yamlText) {
    return [
      ...yamlText.matchAll(/\s*-?\s*([A-Za-z0-9_]+)=.*# CHANGE-ME/gm),
    ].map((match) => match[1]);
  }

  function convertYamlToJson() {
    const yamlText = document.getElementById("yaml-input").value;
    try {
      const yamlData = jsyaml.load(yamlText);
      const requiredEnvVars = extractEnvVars(yamlText);
      const jsonData = {
        $schema: "https://its4nik.github.io/DockStacks/schema.json",
        required_env_vars: requiredEnvVars,
        name: yamlData.name || "unknown",
        services: yamlData.services || {},
        networks: yamlData.networks || {},
      };
      document.getElementById("json-output").innerHTML = `
        <pre><code class="language-json">${Prism.highlight(JSON.stringify(jsonData, null, 2), Prism.languages.json, "json")}</code></pre>
      `;
    } catch (e) {
      document.getElementById("json-output").textContent =
        "Error: " + e.message;
    }
  }

  function copyJSONContent() {
    const textToCopy = document.getElementById("json-output").innerText; // Corrected method
    navigator.clipboard
      .writeText(textToCopy)
      .then(() => {
        alert("Copied this JSON content: " + textToCopy);
      })
      .catch((err) => {
        console.error("Error copying text: ", err);
      });
  }
});
