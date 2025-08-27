# Jekyll Blog Development Commands
# Run `just --list` to see all available commands

# Install Node.js dependencies
install:
    yarn install

# Build webpack assets for production
build:
    yarn build

# Start webpack dev server (for asset development)
dev:
    yarn start

# Start Jekyll development server with local asset loading
serve: build
    JEKYLL_ENV=development bundle exec jekyll serve --source jekyll --host 0.0.0.0 --port 4000

# Start Jekyll server without rebuilding assets (faster restarts)
serve-quick:
    JEKYLL_ENV=development bundle exec jekyll serve --source jekyll --host 0.0.0.0 --port 4000

# Update Ruby dependencies and regenerate gemset.nix
deps:
    bundix --lock

# Install pre-commit hooks
hooks:
    pre-commit install

# Format Nix files
format:
    nixfmt flake.nix

# Clean generated files
clean:
    rm -rf _site jekyll/dist .jekyll-cache .jekyll-metadata node_modules/.cache

# Build site for production (same as CI/CD pipeline)
build-prod: build
    bundle exec jekyll build --source jekyll

# Quick development workflow: build assets and start server
start: build serve

# Development workflow for Giscus CSS changes
giscus: build serve-quick
    @echo "Giscus CSS development ready!"
    @echo "1. Edit css/giscus-custom.css"
    @echo "2. Run 'just build' to rebuild assets"  
    @echo "3. Refresh browser to see changes"
    @echo "Giscus will load CSS from http://localhost:4000/css/giscus-custom.css"

# Show development environment status
status:
    @echo "=== Development Environment Status ==="
    @echo "Ruby version: $(ruby --version)"
    @echo "Node version: $(node --version)"
    @echo "Yarn version: $(yarn --version)"
    @echo "Jekyll version: $(bundle exec jekyll --version)"
    @echo "Just version: $(just --version)"
    @echo ""
    @echo "=== Project Status ==="
    @if [ -d "node_modules" ]; then echo "✓ Node dependencies installed"; else echo "✗ Node dependencies missing (run: just install)"; fi
    @if [ -d "_site" ]; then echo "✓ Site built"; else echo "✗ Site not built (run: just serve or just build-prod)"; fi
    @if [ -d "jekyll/dist" ]; then echo "✓ Webpack assets built"; else echo "✗ Webpack assets missing (run: just build)"; fi

# Show help and available commands (default recipe)
default:
    @just --list