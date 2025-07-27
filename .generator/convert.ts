#!/usr/bin/env bun
import { join } from "path";
import { $ } from "bun";
import type { ThemeEntry } from "./typings/dockstacks";

const GITHUB_RAW =
  "https://raw.githubusercontent.com/Its4Nik/DockStacks/refs/heads/main";

type TemplateEntry = {
  name: string;
  icon: string;
  path: string;
  version: string;
  source: string;
};

async function loadTemplates(): Promise<TemplateEntry[]> {
  console.debug("📦 Loading templates…");
  const out: TemplateEntry[] = [];
  const templateDirs = (await $`ls ../templates`.text()).split("\n");

  for await (const dir of templateDirs) {
    if (!dir) continue;
    console.debug("");
    console.debug(`🔹 Processing template directory: ${dir}`);
    const tplDir = join("../templates", dir);
    const tplJsonPath = join(tplDir, "template.json");

    try {
      const raw = await Bun.file(tplJsonPath).text();
      const { name, version, source } = JSON.parse(raw) as {
        name: string;
        version: number | string;
        source: string;
      };
      console.debug(
        `  🧾 Parsed template: name=${name}, version=${version}, source=${source}`,
      );

      let iconFile: string;
      try {
        iconFile = (await $`ls ${tplDir} | grep "svg\|png"`.text()) ?? "";

        iconFile = iconFile.replaceAll("\n", "");
        iconFile = `${GITHUB_RAW}/templates/${dir}/${iconFile}`;
        console.debug(`  🖼️ Found icon: ${iconFile}`);
      } catch (shellErr) {
        const shellMessage =
          shellErr instanceof Error ? shellErr.message : String(shellErr);
        console.debug(
          `  ℹ️ No icon found in "${dir}", setting default; ${shellMessage}`,
        );
        iconFile = "";
      }

      out.push({
        name,
        icon: iconFile,
        path: `${GITHUB_RAW}/templates/${dir}/template.json`,
        version: String(version),
        source,
      });
    } catch (err) {
      const errMsg = err instanceof Error ? err.message : String(err);
      console.warn(`  ⚠️ Skipping template “${dir}”: ${errMsg}`);
    }
  }

  console.debug(`✅ Loaded ${out.length} templates`);
  return out;
}

async function loadThemes(): Promise<Omit<ThemeEntry, "options">[]> {
  console.debug("🎨 Loading themes…");
  const out: Omit<ThemeEntry, "options">[] = [];
  for await (const dir of (await $`ls ../themes`.text()).split("\n")) {
    if (!dir) continue;
    console.debug(`🔹 Processing theme directory: ${dir}`);
    const themeDir = join("../themes", dir);
    const cssPath = join(themeDir, "theme.css");
    try {
      const css = await Bun.file(cssPath).text();
      console.debug(`  📄 Loaded CSS from ${cssPath}`);

      const nameMatch = css
        .match(/@name\s+(.+?)\s*\*\//)
        ?.slice(1)
        .join(" ");
      const versionMatch = css
        .match(/@version\s+(.+?)\s*\*\//)
        ?.slice(1)
        .join(" ");
      const ownerMatch = css
        .match(/@owner\s+(.+?)\s*\*\//)
        ?.slice(1)
        .join(" ");
      const tagsMatch = css
        .match(/@tags\s+([^\*\/]+)/)?.[1]
        .split(",")
        .map((tag) => tag.trim())
        .filter(Boolean);

      if (!nameMatch || !versionMatch || !ownerMatch || !tagsMatch) {
        throw new Error("Missing @name, @version, @owner, or @tags in CSS");
      }

      let iconColor: string;
      try {
        const accentMatch = css.match(/#[0-9a-fA-F]{6}/);
        if (!accentMatch) {
          throw new Error("Could not find accent color in CSS");
        }
        iconColor = accentMatch[0];
      } catch (shellErr) {
        const shellMessage =
          shellErr instanceof Error ? shellErr.message : String(shellErr);
        console.debug(
          `  ℹ️ No accent color found in "${dir}", setting default; ${shellMessage}`,
        );
        iconColor = "";
      }

      console.debug(`  🖼️ Theme icon color: ${iconColor || "None"}`);

      out.push({
        name: nameMatch,
        icon: iconColor || "",
        cssFile: `${GITHUB_RAW}/themes/${dir}/theme.css`,
        owner: ownerMatch,
        tags: tagsMatch,
      });
    } catch (err) {
      console.warn("  ⚠️ Skipping theme “%s”: %s", dir, err.message);
    }
  }
  console.debug(`✅ Loaded ${out.length} themes`);
  return out;
}

async function generateReadme(
  templates: TemplateEntry[],
  themes: Omit<ThemeEntry, "options">[],
) {
  const header = `# DockStacks 🐳

![DockStacks Logo](./.github/DockStat.png)

**DockStacks** is a curated repository of Docker Compose templates for popular applications. Simplify your deployments with ready-to-use stacks!

---

## Features ✨

- **Pre-built Templates**: Quickly deploy apps like Nginx, PostgreSQL, or WordPress.
- **Community-Driven**: Submit your own stacks or improve existing ones.
- **Easy Integration**: Compatible with DockStat and DockStatAPI.

## Getting Started 🚀

1. **Browse Templates**: Explore the [templates](./templates) directory.
2. **Deploy**: Use a DockStat or another tool to deploy your chosen stack.
3. **Contribute**: Share your Docker setups by following our [contribution guide](./CONTRIBUTE.md).

---

## Templates 📦

| Icon | Name | Version | Source |
|------|------|---------|--------|
${templates
  .map(
    (t) =>
      `| ![icon](${t.icon || "No Icon available"}) | ${t.name} | ${t.version} | [Source](${t.source}) |`,
  )
  .join("\n")}

---

## Themes 🎨

| Icon | Name | Version | Owner |
|------|------|---------|-------|
${themes
  .map((t) => `| ${t.icon || "No Icon available"} | ${t.name} | ${t.owner} |`)
  .join("\n")}

---

## Contributing 🙌

We welcome community templates! Learn how to add yours in the [CONTRIBUTE.md](./CONTRIBUTE.md) guide.

---

[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
`;

  await Bun.write("../README.md", header);
  console.log("📘 Generated README.md with templates and themes table.");
}

async function main() {
  console.log("⏳ Building Index.json and README…");
  const [templates, themes] = await Promise.all([
    loadTemplates(),
    loadThemes(),
  ]);

  const index = { templates, themes };

  await Bun.write("../Index.json", JSON.stringify(index, null, 2));
  console.log("✅ Wrote Index.json");

  await generateReadme(templates, themes);
}

main().catch((err) => {
  console.error("❌ Unhandled error:", err);
  process.exit(1);
});
