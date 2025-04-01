# Retro Dev Blog

My personal blog with an 80s retro aesthetic, built for GitHub Pages using Jekyll.

The initial prototype is vibe-coded using Windsurf and Junie.

## Features

- 80s-inspired design with CRT screen effect
- Retro color scheme with classic green terminal text
- Responsive layout
- Scanline animation effect
- Glowing text effects
- Markdown support for blog posts

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

## Working with Jekyll

Every time the dependencies in `Gemfile` change, `Gemfile.lock` and `gemset.nix` have to be rebuilt. 
This is done automatically by a pre-commit hook, if you install it using `pre-commit install`.

To use binary caches from cachix, run:

```shell
cachix use forketyfork
```

To run the project locally:
```shell
nix develop
bundle exec jekyll serve
```
