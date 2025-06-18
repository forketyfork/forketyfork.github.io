# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Jekyll-based personal blog with an 80s retro aesthetic, deployed on GitHub Pages. The site features CRT screen effects, scanline animations, and a green terminal color scheme.

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
   bundle exec jekyll serve
   ```

## Key Commands

- **Local development**: `bundle exec jekyll serve` (after `nix develop`)
- **Update dependencies**: `bundix --lock` (regenerates Gemfile.lock and gemset.nix)
- **Install pre-commit hooks**: `pre-commit install`

## Architecture

### Jekyll Configuration
- Main config: `_config.yml` 
- Plugins: jekyll-sitemap, jekyll-seo-tag
- Permalink structure: `/blog/:year/:month/:day/:title/`

### Layout System
- `_layouts/default.html`: Main layout with retro CRT styling, custom cursor, and navigation
- `_layouts/post.html`: Individual blog post layout
- Retro styling split across `styles.css` and `cursor.css`

### Content Structure
- `_posts/`: Blog posts in YYYY-MM-DD-title.md format
- `pages/`: Static pages (about.html, blog.html)
- `index.html`: Homepage showing latest post

### Dependency Management
- Ruby 3.4.2 with Jekyll 4.4.1
- Nix flake manages Ruby environment and gems
- Pre-commit hook automatically updates `gemset.nix` when `Gemfile` changes
- **Important**: After changing `Gemfile`, both `Gemfile.lock` and `gemset.nix` must be regenerated

### Styling
The retro aesthetic is achieved through:
- CRT screen effects and scanlines
- Green terminal color scheme
- Glitch effects on headers
- Custom cursor with hover animations
- Responsive design

## Blog Post Creation

New posts go in `_posts/` with format `YYYY-MM-DD-title.md` and require front matter:
```yaml
---
layout: post
title: "Post Title"
date: YYYY-MM-DD
tags: [tag1, tag2]
---
```