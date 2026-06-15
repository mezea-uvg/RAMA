# RAMA — GitHub Pages Setup Guide

Step-by-step instructions for publishing the RAMA project site.

---

## Prerequisites

- A GitHub account
- Git installed locally (`git --version` to check)

---

## Step 1 — Create the GitHub repository

1. Go to [github.com/new](https://github.com/new)
2. Repository name: `rama` (or `RAMA` — GitHub is case-insensitive for URLs)
3. Set visibility to **Public** (required for free GitHub Pages)
4. Do **not** initialize with a README — you already have files
5. Click **Create repository**

---

## Step 2 — Connect and push your local files

In your terminal, navigate to the site folder and run:

```bash
cd path/to/rama-site

git init
git add .
git commit -m "Initial RAMA site"

git remote add origin https://github.com/YOUR_USERNAME/rama.git
git branch -M main
git push -u origin main
```

Replace `YOUR_USERNAME` with your actual GitHub username.

---

## Step 3 — Enable GitHub Pages

1. On your repository page, click **Settings** (top nav)
2. In the left sidebar, click **Pages**
3. Under **Source**, select **Deploy from a branch**
4. Branch: `main` · Folder: `/ (root)`
5. Click **Save**

GitHub will build and deploy within 1–2 minutes. Your site will be live at:

```
https://YOUR_USERNAME.github.io/rama/
```

---

## Step 4 — Update placeholder URLs

Before or after pushing, replace `YOUR_USERNAME` in `index.html`:

```bash
# macOS/Linux
sed -i '' 's/YOUR_USERNAME/your-actual-username/g' index.html

# Linux (without '')
sed -i 's/YOUR_USERNAME/your-actual-username/g' index.html
```

Or find-and-replace `https://github.com/YOUR_USERNAME/rama` in your editor.

---

## Step 5 — Add your content files

Place real files in the correct folders:

| File | Destination |
|---|---|
| Paper PDF | `paper/DAFx26_RAMA.pdf` |
| Citation BibTeX | `paper/citation.bib` |
| Supplementary derivations | `supplementary/derivations.pdf` |
| Circuit matrices | `supplementary/circuit_matrices.pdf` |
| Benchmark reproduce script | `benchmarks/reproduce.md` |
| VST plugin README | `vst-demo/README.md` |

After adding files:

```bash
git add .
git commit -m "Add paper, supplementary, and benchmark files"
git push
```

---

## Step 6 — Verify the live site

- Open `https://YOUR_USERNAME.github.io/rama/`
- Check the nav links scroll correctly
- Test the BibTeX copy button
- Confirm the oscilloscope canvas animation plays in the hero
- Check mobile layout at ~375px width (browser DevTools → responsive mode)

---

## Custom domain (optional)

If you have a domain (e.g. `rama.yourdomain.com`):

1. In Settings → Pages → Custom domain, enter your domain
2. In your DNS, add a CNAME record: `rama` → `YOUR_USERNAME.github.io`
3. GitHub will provision HTTPS automatically within minutes
4. Check **Enforce HTTPS** once the certificate is issued

---

## Updating the site

After any edit:

```bash
git add .
git commit -m "Update: describe what changed"
git push
```

GitHub Pages re-deploys automatically on every push to `main`.

---

## No Jekyll needed

This site is plain HTML/CSS/JS — no build step required. GitHub Pages serves it as static files directly. If you ever see a `_config.yml`, you can safely ignore it for this setup.

---

## Troubleshooting

| Problem | Fix |
|---|---|
| Page shows README instead of site | Make sure `index.html` is in the repo root |
| CSS not loading | Check paths are relative (`assets/css/style.css`, not `/assets/...`) |
| Canvas animation missing | Open DevTools console, check for JS errors |
| Page not found (404) | Wait 2 min after enabling Pages; hard-refresh |
