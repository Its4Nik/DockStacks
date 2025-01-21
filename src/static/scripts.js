document.addEventListener("DOMContentLoaded", async () => {
  const gridContainer = document.getElementById("grid-container");
  const modal = document.getElementById("modal");
  const modalBody = document.getElementById("modal-body");
  const closeModal = document.getElementById("close-modal");

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
        document.getElementById(`description-${template}`).textContent =
          description.length > 50
            ? `${description.slice(0, 47)}...`
            : description;
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
    let readme = await fetch(`./templates/${template}/README.html`).then(
      (res) => res.text(),
    );
    modalBody.innerHTML = `
            <div style="height: 80vh; overflow-y: auto;">
              ${readme}
            </div>
            <p><a href="./templates/${template}/schema.json" target="_blank">View Raw Schema</a></p>
        `;
    modal.style.display = "flex";
  }

  closeModal.addEventListener("click", () => {
    modal.style.display = "none";
  });

  window.addEventListener("click", (event) => {
    if (event.target === modal) {
      modal.style.display = "none";
    }
  });
});
