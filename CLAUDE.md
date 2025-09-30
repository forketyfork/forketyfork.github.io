# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Jekyll-based personal blog with an 80s retro aesthetic, deployed on GitHub Pages.

## Development Environment

This project uses Nix for reproducible development environments with direnv for automatic loading:

### Option 1: Automatic Environment (Recommended)

1. Install direnv:
   ```shell
   # macOS
   brew install direnv
   # Add to your shell rc file: eval "$(direnv hook bash)" or eval "$(direnv hook zsh)"
   ```

2. Setup cachix and allow direnv:
   ```shell
   cachix use forketyfork
   direnv allow
   ```

3. Start development (environment loads automatically):
   ```shell
   just serve
   ```

### Option 2: Manual Environment

1. Setup cachix for binary caches:
   ```shell
   cachix use forketyfork
   ```

2. Enter development environment:
   ```shell
   nix develop
   ```

3. Start development server:
   ```shell
   just serve
   ```

## Key Commands

All development commands are available via `just` (run `just --list` to see all options):

- **Local development**: `just serve` (builds assets and starts server)
- **Quick restart**: `just serve-quick` (skips asset rebuild)
- **Build assets only**: `just build` (webpack production build)
- **Update dependencies**: `just deps` (regenerates Gemfile.lock and gemset.nix)
- **Install pre-commit hooks**: `just hooks`
- **Format Nix files**: `just format`
- **Clean generated files**: `just clean`
- **Environment status**: `just status` (shows setup status)

## Architecture

### Jekyll Configuration
- The source files for static site generation are located in jekyll, this is the only folder that jekyll works on, so you need to add `--source jekyll` to all jekyll commands.
- Main config: `jekyll/_config.yml` 
- Plugins are defined in `Gemfile`, some custom plugins are defined in `jekyll/_plugins`
- Permalink structure: `/blog/:year/:month/:day/:title/`

### Webpack configuration
- The site uses [HTML5 Boilerplate](https://github.com/h5bp/html5-boilerplate) for common stuff and adaptive layout.

### Layout System
- `jekyll/_layouts/default.html`: Main layout for all pages
- `jekyll/_layouts/post.html`: Individual blog post layout
- Styling is in the `css` folder

### Content Structure
- `jekyll/_posts/`: Blog posts in YYYY-MM-DD-title.md format
- `jekyll/pages/`: Static pages (about.html)
- `jekyll/index.html`: Homepage showing latest post

### Dependency Management
- Ruby 3.4.3 with Jekyll 4.4.1
- Nix flake manages Ruby environment and gems
- Pre-commit hook automatically updates `gemset.nix` when `Gemfile` changes
- **Important**: After changing `Gemfile`, both `Gemfile.lock` and `gemset.nix` must be regenerated

## Blog Post Creation

### English Posts (Default)
New posts go in `jekyll/_posts/` with format `YYYY-MM-DD-title.md` and require front matter:
```yaml
---
layout: post
title: "Post Title"
date: YYYY-MM-DD
tags: [tag1, tag2]
---
```

### Multilingual Posts
The site supports English (default), German, and Russian using [jekyll-polyglot](https://github.com/untra/polyglot).

**Directory structure:**
- English posts: `jekyll/_posts/YYYY-MM-DD-title.md`
- German posts: `jekyll/_posts/de/YYYY-MM-DD-title.md`
- Russian posts: `jekyll/_posts/ru/YYYY-MM-DD-title.md`

**Important: Translated posts must:**
1. Have the **exact same filename** as the English version (e.g., `2025-08-27-my-post.md`)
2. Include a `lang` frontmatter variable (e.g., `lang: de` or `lang: ru`)
3. Be placed in the appropriate language subdirectory

**Example:**
```yaml
# jekyll/_posts/de/2025-08-27-my-post.md
---
layout: post
title: "Mein Artikel"
date: 2025-08-27
tags: [tag1, tag2]
lang: de
---
```

**Translations:**
- UI translations are in `jekyll/_data/translations.yml`
- Language switcher appears in the navigation (EN | DE | RU)
- URLs are automatically prefixed with language code (e.g., `/de/blog/...`, `/ru/blog/...`)
- English (default language) has no prefix in URLs
- Polyglot automatically filters posts by language on each language version of the site

## Deployment & CI/CD

### GitHub Actions Workflow
- The site is automatically deployed via GitHub Actions on push to `main` branch
- Workflow file: `.github/workflows/jekyll.yml`
- Deployment process:
  1. Sets up Nix environment with cachix for faster builds
  2. Runs webpack build (`yarn build`) for asset bundling
  3. Builds Jekyll site with `bundle exec jekyll build --source jekyll`
  4. Deploys to GitHub Pages

### Asset Build Process
- **Webpack configuration**: `webpack.common.js`, `webpack.config.dev.js`, `webpack.config.prod.js`
- **Development**: `yarn start` (webpack dev server)
- **Production**: `yarn build` (minified assets)
- **Jekyll plugin**: `jekyll/_plugins/copy_dist.rb` copies webpack output to Jekyll

### Testing & Quality
- **Pre-commit hooks**: Automatically updates `gemset.nix` when `Gemfile` changes
- **Nix flake validation**: Ensures `gemset.nix` stays in sync with `Gemfile.lock`

## Giscus Comments Development

The blog uses Giscus for comments with custom 80s retro styling. For local development and testing of comment styles:

### Setup
- Custom CSS: `css/giscus-custom.css`
- Giscus configuration: `jekyll/_layouts/post.html`
- CORS plugin: `jekyll/_plugins/cors_headers.rb` (enables local CSS loading)

### Development Workflow
1. **Start Giscus development**: Run `just giscus` (builds assets and starts server)
2. **Edit comment styles**: Modify `css/giscus-custom.css`
3. **Rebuild assets**: Run `just build` to update webpack output
4. **Test locally**: Giscus will load CSS from `http://localhost:4000/css/giscus-custom.css`

### Environment Detection
- **Development**: Uses local CSS URL for immediate testing
- **Production**: Uses production URL `https://forketyfork.github.io/css/giscus-custom.css`
- **CORS headers**: Automatically added in development to allow cross-origin CSS loading

### Important Notes
- Use `just serve` for automatic proper environment setup
- The CORS plugin only activates in development mode  
- Webpack assets are automatically built with `just serve` and `just giscus`
- Use `just serve-quick` for faster restarts when assets don't need rebuilding