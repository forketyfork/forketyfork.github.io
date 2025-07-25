# Forketyfork Dev Blog

A retro-styled developer blog with an 80s aesthetic, built for GitHub Pages using Jekyll and deployed automatically via GitHub Actions.

## Quick Start

1. Setup development environment:
   ```shell
   cachix use forketyfork
   nix develop
   ```

2. Install pre-commit hooks:
   ```shell
   pre-commit install
   ```

3. Run locally:
   ```shell
   bundle exec jekyll serve --source jekyll
   ```

## Architecture

### Project Structure
- **`jekyll/`**: Jekyll source files (posts, layouts, config)
- **`css/`**: Stylesheets for the retro 80s theme
- **`js/`**: JavaScript files bundled with Webpack
- **`img/`**: Static images and assets
- **`_site/`**: Generated site output (auto-generated)

### Technology Stack
- **Jekyll 4.4.1**: Static site generator
- **Ruby 3.4.3**: Runtime environment
- **Webpack 5**: Asset bundling and optimization
- **Nix**: Reproducible development environment
- **GitHub Actions**: Automated deployment to GitHub Pages

### Deployment
The site is automatically deployed via GitHub Actions when pushing to the `main` branch:
1. Webpack builds and bundles assets
2. Jekyll generates the static site
3. Site is deployed to GitHub Pages

## Writing Posts

1. Create a new markdown file in `jekyll/_posts/`
2. Name it using the format: `YYYY-MM-DD-title.md`
3. Add the following front matter:
   ```yaml
   ---
   layout: post
   title: "Your Post Title"
   date: YYYY-MM-DD
   tags: [Tag1, Tag2, Tag3]
   ---
   ```
4. Write your post content in Markdown below the front matter
5. Commit and push to GitHub - your post will be automatically built and published!

## Customization

- Edit `jekyll/_config.yml` to modify site settings
- Adjust colors and effects in `css/custom.css`
- Modify layouts in `jekyll/_layouts/`
- Update webpack configuration in `webpack.*.js` files

## Development

This project uses Nix for reproducible development environments and manages Jekyll dependencies through bundler.

### Key Commands
- **Local development**: `bundle exec jekyll serve --source jekyll` (after `nix develop`)
- **Asset building**: `yarn build` (production) or `yarn start` (development)
- **Update dependencies**: `bundix --lock` (regenerates Gemfile.lock and gemset.nix)
- **Install pre-commit hooks**: `pre-commit install`

### Dependencies
- Ruby 3.4.3 with Jekyll 4.4.1
- Node.js with Webpack 5 for asset bundling
- Nix flake manages the complete development environment
- Pre-commit hooks automatically update `gemset.nix` when `Gemfile` changes

### Important Notes
- Jekyll source files are in the `jekyll/` directory - add `--source jekyll` to all Jekyll commands
- After changing `Gemfile`, both `Gemfile.lock` and `gemset.nix` are automatically regenerated by the pre-commit hook
- The Nix flake ensures `gemset.nix` stays in sync with `Gemfile.lock`
- Use `bundix --lock` to manually regenerate both files if needed

## License

MIT
