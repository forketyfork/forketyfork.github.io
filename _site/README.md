# Retro Dev Blog

A personal developer blog with an 80s retro aesthetic, built for GitHub Pages using Jekyll.

## Features

- 80s-inspired design with CRT screen effect
- Retro color scheme with classic green terminal text
- Responsive layout
- Scanline animation effect
- Glowing text effects
- Markdown support for blog posts

## Setup

1. Fork this repository
2. Enable GitHub Pages in your repository settings
3. Install Jekyll and dependencies:
   ```bash
   gem install bundler jekyll
   bundle install
   ```
4. Run locally:
   ```bash
   bundle exec jekyll serve
   ```
5. Your blog will be available at `https://[your-username].github.io/[repository-name]`

## Writing Posts

1. Create a new markdown file in the `_posts` directory
2. Name it using the format: `YYYY-MM-DD-title.md`
3. Add the following front matter at the top of your post:
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

- Edit `_config.yml` to modify site settings
- Adjust colors and effects in `styles.css`
- Modify layouts in the `_layouts` directory

## License

MIT
