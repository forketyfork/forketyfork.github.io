---
title: "Running 9 AI Coding Agents at Once: The Terminal I Built to Keep Up"
date: 2026-01-21
tags: [AI, Agentic coding, Claude Code, Architect, Terminal]
---

I run multiple AI coding agents simultaneously because I often need to work on several tasks at once. One agent implements a feature, another does a code review, another improves my dev setup, yet another helps me keep my Obsidian notes up to date.

The problems I've faced:

- I kept forgetting that I'd spawned an agent to work on some task, only to find out at the end of the day that it had been waiting for my approval for hours.
- I tried to use git worktrees to parallelize tasks, but they're cumbersome to manage.
- I tried other terminals, but they either lack native agentic support or are overloaded with AI features that rub me the wrong way.
- I tried tools that wrap agent executions into a UI, but always reverted back to the terminal because they didn't provide the level of control I needed, or the ability to use the same window for different tasks. Agent was in one place, terminal in another.

## The attention problem

Here's what happens when you run 4 Claude Code sessions in multiple terminal tabs: nothing, visually. All four tabs look the same. One agent finishes and sits there, waiting for your next prompt. Another hits a permission check and needs approval. You don't notice because you're focused on tab 3, watching it churn through a file. Twenty minutes later you realize agent 1 has been idle the whole time.

I tried the obvious solutions — desktop notifications, but they come and go at the operating system's whim. Multiple terminal windows arranged carefully. A second monitor dedicated to "the agents." None of it worked because the fundamental problem remained: terminals don't know what's running inside them.

A shell prompt looks the same whether the last command succeeded, failed, or is waiting for human input. There's no semantic information.

## What I built

[Architect](https://github.com/forketyfork/architect) is a terminal I wrote specifically for this workflow. Show all sessions in a grid, make it easy to switch between them, make it visually obvious which ones need attention.

When an agent finishes a task, the cell hue changes. When it's waiting for approval, it glows. At a glance, I know where to focus.

<video class="post-video" autoplay loop muted playsinline controls>
  <source src="/img/agents.mp4" type="video/mp4">
</video>

That's it. That's the feature.

Everything else — the smooth animations, the expand/collapse, the keyboard shortcuts — exists to make this core loop fast. See the grid. Spot the agent that needs you. Expand. Respond. Collapse. Back to the grid.

## The workflow

I start with a single terminal. When I need another, I hit ⌘N and the grid expands automatically. When I'm done with one, ⌘W closes it and the grid contracts. If I need to focus on a specific terminal, I hit ⌘Enter, or do a long Esc hold to pop back to the grid.

<video class="post-video" autoplay loop muted playsinline controls>
  <source src="/img/grid.mp4" type="video/mp4">
</video>

If I need multiple tasks in the same repo, I hit ⌘T to open a worktree popup. ⌘0 creates a new worktree, ⌘1/⌘2/⌘3... switches to an existing one. I can delete worktrees from the same popup. The integration works by sending git commands to the terminal — fully traceable, no magic.

<video class="post-video" autoplay loop muted playsinline controls>
  <source src="/img/worktrees.mp4" type="video/mp4">
</video>

## Status detection

It's based on hooks. Many agents support them, so it's not limited to the big 3. I provide a Python script you can call to highlight the cell where it's running.

I learned a lot of agent quirks along the way:

- **Claude Code** first signals it's done (`Stop`), then triggers another hook (`Notification`) after ~10 seconds if you don't react. So the cell turns green, then yellow.
- **Gemini** hooks have to be [explicitly enabled in settings](https://github.com/google-gemini/gemini-cli/blob/main/docs/get-started/configuration.md). It also sends its `AfterAgent` notification after every step instead of just once at the end — [known issue](https://github.com/google-gemini/gemini-cli/issues/14596).
- **Codex** [doesn't support hooks](https://github.com/openai/codex/discussions/2150), just a simple notification script after every agent turn. No permission request notification, sadly.

## Why Zig?

I wanted to learn Zig, and terminal emulators are a good project for it. Also, Architect builds on [ghostty-vt](https://github.com/ghostty-org/ghostty), which is written in Zig — using the same language meant I could integrate directly without FFI overhead. SDL3 for rendering, ghostty-vt for terminal emulation, Zig for glue.

## What's missing

Architect is early. I use it daily, but there are gaps:

- **Linux support**: macOS only for now.
- **Customizable keybindings**: Hardcoded. You get what I like.
- **Windows**: Not happening anytime soon.
- **Bugs and UI quirks**: Plenty.

Agent detection is also limited to a handful of tools.

## Try it

If you're running multiple AI agents and fighting the same attention problem, give Architect a shot.

[Download the latest release](https://github.com/forketyfork/architect/releases) or install via Homebrew:
```bash
brew tap forketyfork/architect https://github.com/forketyfork/architect
brew install architect
cp -r $(brew --prefix)/Cellar/architect/*/Architect.app /Applications/
```

Issues and PRs welcome.

---

I've been building a few other tools for multi-agent workflows:

- [**Stepcat**](https://github.com/forketyfork/stepcat) — orchestrates multi-step implementation plans with Claude Code and Codex
- [**Marx**](https://github.com/forketyfork/marx) — runs Claude, Codex, and Gemini in parallel for PR code review
- [**Claude Nein**](https://github.com/forketyfork/claude-nein) — macOS menu bar app to track Claude Code spending
