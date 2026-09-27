# Knot website

The Knot project website is a static Astro site published to GitHub Pages.

## Local development

Build Knot from the repository root, then use it to install the website dependencies.

```sh
./scripts/build-knot
cd website
knot install --offline
node node_modules/astro/astro.js dev
```

Build the static output with `node node_modules/astro/astro.js build`.
