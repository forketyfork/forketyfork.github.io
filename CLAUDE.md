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

3. Serve the site locally:
   ```shell
   bundle exec jekyll serve --source jekyll
   ```

## Key Commands

- **Local development**: `bundle exec jekyll serve --source jekyll` (after `nix develop`)
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
- Ruby 3.4.2 with Jekyll 4.4.1
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