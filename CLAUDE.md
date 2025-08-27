# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Jekyll-based personal blog with an 80s retro aesthetic, deployed on GitHub Pages.

## Development Environment

This project uses Nix for reproducible development environments:

1. Setup cachix for binary caches:
   ```shell
   cachix use forketyfork
   ```

2. Enter development environment:
   ```shell
   nix develop
   ```

3. Build webpack assets (required for CSS/JS):
   ```shell
   yarn install && yarn build
   ```

4. Serve the site locally:
   ```shell
   JEKYLL_ENV=development bundle exec jekyll serve --source jekyll --host 0.0.0.0 --port 4000
   ```

## Key Commands

- **Local development**: 
  1. `yarn build` (build webpack assets)
  2. `JEKYLL_ENV=development bundle exec jekyll serve --source jekyll --host 0.0.0.0 --port 4000` (after `nix develop`)
- **Update dependencies**: `bundix --lock` (regenerates Gemfile.lock and gemset.nix)
- **Install pre-commit hooks**: `pre-commit install`

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

New posts go in `jekyll/_posts/` with format `YYYY-MM-DD-title.md` and require front matter:
```yaml
---
layout: post
title: "Post Title"
date: YYYY-MM-DD
tags: [tag1, tag2]
---
```

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
1. **Edit comment styles**: Modify `css/giscus-custom.css`
2. **Rebuild assets**: Run `yarn build` to update webpack output
3. **Test locally**: Giscus will load CSS from `http://localhost:4000/css/giscus-custom.css`

### Environment Detection
- **Development**: Uses local CSS URL for immediate testing
- **Production**: Uses production URL `https://forketyfork.github.io/css/giscus-custom.css`
- **CORS headers**: Automatically added in development to allow cross-origin CSS loading

### Important Notes
- Always run with `JEKYLL_ENV=development` for proper local CSS loading
- The CORS plugin only activates in development mode
- Webpack build is required before Jekyll serve to generate assets in `jekyll/dist/`