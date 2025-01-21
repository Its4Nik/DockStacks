import { readdirSync, writeFileSync } from "fs";
import path from "path";

const templateDir = "./src/templates";
const templates = readdirSync(templateDir).filter((file) =>
  readdirSync(path.join(templateDir, file)).includes("schema.json"),
);

writeFileSync(
  "./src/static/templates.json",
  JSON.stringify(templates, null, 2),
);
