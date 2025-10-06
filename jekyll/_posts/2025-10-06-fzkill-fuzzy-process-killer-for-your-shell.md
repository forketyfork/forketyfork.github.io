---
layout: post
title: "fzkill: Fuzzy Process Killer for Your Shell"
date: 2025-10-06
tags: [CLI, Shell, Productivity, fzf]
---

I don't know about you, but for me, killing processes from the command line always involved a ritual: run `ps aux`, scroll through output, find the target, copy the PID, then `kill` it. Or maybe grep for a pattern, parse column 2, and hope I picked the right one.

Now I use a better way. Meet `fzkill`: a shell function that I use to interactively fuzzy-search my running processes and kill them with immediate visual feedback.

## What it does

```zsh
fzkill() {
  local pid=$(ps aux | fzf --header="Select a process to kill" --preview="echo {}" | awk '{print $2}')

  if [ -z "$pid" ]; then
    print -P "%F{yellow}❌ No process selected, operation canceled%f"
    return 1
  fi

  if kill "$pid" 2>/dev/null; then
    print -P "%F{green}✅ Successfully killed process $pid%f"
  else
    print -P "%F{red}⚠️  Failed to kill process $pid (may require sudo or process doesn't exist)%f"
    return 1
  fi
}
```

Run `fzkill`, start typing to filter processes, hit Enter, done. I get:
- 🟡 **⚠️** when I cancel (press Esc or Ctrl+C)
- 🟢 **✅** when the process is killed successfully
- 🔴 **❌** when it fails (permissions or the process disappeared)

## How to install

### Prerequisites

You need [fzf](https://junegunn.github.io/fzf/) installed. Most package managers have it, I use brew:

```bash
# macOS
brew install fzf
```

### For Zsh

Add the function to your `~/.zshrc`:

```zsh
fzkill() {
  local pid=$(ps aux | fzf --header="Select a process to kill" --preview="echo {}" | awk '{print $2}')

  if [ -z "$pid" ]; then
    print -P "%F{yellow}⚠️ No process selected, operation canceled%f"
    return 1
  fi

  if kill "$pid" 2>/dev/null; then
    print -P "%F{green}✅ Successfully killed process $pid%f"
  else
    print -P "%F{red}❌  Failed to kill process $pid (may require sudo or process doesn't exist)%f"
    return 1
  fi
}
```

Reload your shell:
```bash
source ~/.zshrc
```

### For Bash

Add to your `~/.bashrc`:

```bash
fzkill() {
  local pid=$(ps aux | fzf --header="Select a process to kill" --preview="echo {}" | awk '{print $2}')

  if [ -z "$pid" ]; then
    echo -e "\033[0;33m⚠️ No process selected, operation canceled\033[0m"
    return 1
  fi

  if kill "$pid" 2>/dev/null; then
    echo -e "\033[0;32m✅ Successfully killed process $pid\033[0m"
  else
    echo -e "\033[0;31m❌  Failed to kill process $pid (may require sudo or process doesn't exist)\033[0m"
    return 1
  fi
}
```

Reload:
```bash
source ~/.bashrc
```

## Design notes

**Why `kill` instead of `kill -9`?**
SIGTERM (the default) lets processes clean up gracefully: flush buffers, close connections, save state. SIGKILL (`-9`) is immediate and brutal, leaving the proces no time to cleanup.

**Why fzf?**
Interactive fuzzy search is better than grepping. You see what you're about to kill, and you can type partial matches: "chro" finds Chrome, "node" finds all Node processes.

## Usage tips

- **Filter fast**: Start typing immediately after running `fzkill`. "python", "node", "postgres" - fzf narrows as you type.
- **Preview is helpful**: The preview pane shows the full `ps aux` line, so you can double-check before killing.
- **Cancel safely**: Just hit Esc or Ctrl+C if you change your mind.
- **Permissions**: If you get ⚠️, you might need `sudo`. Or the process died between selection and kill.

## Variants

- Want SIGKILL by default? Change `kill "$pid"` to `kill -9 "$pid"`.
- Want to kill multiple processes? Pipe through `xargs` and adapt the selection logic.
- Want to filter by user? Add `| grep $USER` before fzf.
