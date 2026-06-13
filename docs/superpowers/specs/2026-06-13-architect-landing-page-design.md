# Architect Landing Page — Design Spec

Date: 2026-06-13

## Goal

Add a dedicated landing page for the **Architect** terminal project to the
personal blog/site. The page matches the existing 80s-retro aesthetic but uses a
**greenish color palette** to set it apart, in line with Architect's existing
green branding.

## Routing & Structure

- New page: `jekyll/pages/architect.html`
  - `layout: default`
  - `permalink: /architect/`
  - SEO description in front matter.
- All page content wrapped in `<div class="architect-landing">` so the green
  palette is scoped to this page only.
- Nav: add an **Architect** entry to the header nav and footer nav in
  `jekyll/_layouts/default.html`, with active state on `/architect/`.
  - Add a `nav.architect` key to `jekyll/_data/translations.yml` for `en`/`de`/`ru`
    (label "Architect" in all three; page content itself is English-only).

## Green Palette (scoped)

The site recolors entirely through CSS custom properties defined in
`css/custom.css` (`--primary-color`, `--secondary-color`, `--accent-color`,
`--background-color`, grid/glow colors). Components reference these variables, so
redefining them on `.architect-landing` recolors the page with no global impact.

Target family (phosphor terminal green):
- `--primary-color`: bright phosphor green (CTAs, links, borders)
- `--secondary-color`: deep teal-green (headings)
- `--accent-color`: lime/chartreuse (contrast, prompts)
- `--background-color`: near-black green
- header/footer glow recolored to green within scope

The site header/footer (outside `main.content`) keep the site's pink, so the
page reads as a distinct green zone while site chrome stays consistent.

## Page Sections (full product landing)

1. **Hero** — large ARCHITECT title (green gradient), tagline
   "A terminal built for multi-agent AI coding workflows", short subtext,
   primary CTAs (Download for macOS → releases, View on GitHub), hero
   grid-view screenshot.
2. **The problem** — short terminal-window-styled block describing the
   multi-agent attention problem (parallel agents go unnoticed).
3. **Feature highlights** — cards, each a fresh screenshot + title + blurb:
   status glow, dynamic grid (⌘N/⌘Enter), worktree picker (⌘T), recent folders
   (⌘O), diff review (⌘D), reader mode (⌘R). Capture more states than needed,
   keep the best ~4–6.
4. **Install** — terminal-styled block with Homebrew + curl commands, plus the
   early-stage / macOS-only note.
5. **Related tools + story** — Stepcat / Marx / Claude Nein links and a link to
   the existing blog post for the deeper story.

## Screenshots (fresh)

- Launch `/Applications/Architect.app` (installed) via `open`.
- Drive via AppleScript System Events keystrokes (⌘N, ⌘Enter, ⌘T, ⌘O, ⌘D, ⌘R).
- Read window bounds via System Events; capture region with `screencapture -R`.
- Steer into representative states; attempt status-glow via a real agent/hook,
  falling back to the strongest stable states if flaky.
- Optimize PNGs (resize/compress via `sips`) and save to `jekyll/img/architect/`
  (served at `/img/architect/...`, matching the existing `/img/*.mp4` pattern).

## Workflow Usage (ultracode)

- A workflow to draft + judge landing copy (tagline, feature blurbs) from
  several angles before writing the HTML.
- A workflow for a final multi-dimension review of the built page (palette
  consistency, responsive layout, link correctness, accessibility/SEO).
- Screenshot capture is done directly by the main agent — it is sequential GUI
  automation on a single app instance and does not parallelize.

## Verification

- `just build` (webpack assets) then `just serve`; open `/architect/` and
  iterate on the real page. Confirm: green palette scoped correctly, nav link +
  active state, screenshots load, CTAs link correctly, responsive at mobile
  widths.

## Out of Scope

- DE/RU translations of the page body (English-only).
- Changes to existing pages beyond nav additions.
- Reusing the existing illustrated hero image / demo videos (fresh screenshots
  only, per request).
