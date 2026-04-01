---
layout: post
title: "Experiment-Driven Dotfiles with Claude Code"
date: 2025-09-11
tags: []
---

# Experiment-Driven Dotfiles with Claude Code

I've been using an experiment-driven dotfiles management, and wanted to share my workflow. The idea behind is that I don't want to just randomly install stuff, I want it logged and revertable. I'm not yet fully bought on the Nix way of things, and I use Mac anyway, so some decision log and automation around that seemed like a good idea.


This workflow treats every change as a **reversible experiment** with three explicit stages:

1) **Experiment** in `zshrc` behind clearly marked fences.
2) **Apply** by promoting the change that proved its worth into my configuration (I use nix-darwin for most stuff, brew to install something that evolves too quickly or is just broken in nixpkgs).
3) **Rollback** cleanly, with verification, if the experiment flops.

The glue is three **Claude Code** commands living in `.claude/commands`: **`/experiment`**, **`/apply`**, **`/rollback`**. They write the right things in the right places and force me to keep the paper trail honest.

## The core idea

- **Experiments live in my `.zshrc`** and are bounded by markers that I can grep, move, or delete in one shot:
  ```bash
  ## [exp] YYYY-MM-DD: name: Description
  # …my trial change…
  ## /[exp]
  ```
- **Apply** = migrate the install/config into nix-darwin (`nix/homebrew.nix`, `nix/system-packages.nix`, `nix/shell.nix`), remove the experimental fence from `.zshrc`, and move the docs in `apply.md` to the **Applied experiments** section.
- **Rollback** = uninstall or undo, whether the change is still fenced in `.zshrc` or already in nix-darwin. Always verify the tool really disappeared.

## Command reference (Claude Code)

These are Markdown commands intended for Claude Code; you run them as chat slash-commands. Each one has a clear contract and comes with example scaffolding for **`jdk-24`**.

### `/experiment <name> "<description>"` — create a new experiment

Creates a fresh fenced block in `zshrc`, plus matching stubs in `apply.md` and `rollback.md`.

**What it does**
1) Parse name + description.
2) Stamp today’s date (format `YYYY-MM-DD`).
3) Add a fenced experiment to `zshrc`.
4) Document permanent steps in `apply.md`.
5) Document rollback steps and **Verify** checks in `rollback.md`.
6) Print a concise summary of what was created.

**Rules/notes**
- Name is **lowercase-kebab**.
- Use `--quiet` for brew installs.
- Include proper markers `## [exp]` and `## /[exp]`.
- For rollback, include **uninstall** and **verification**.
- Consider the tool type (runtime vs CLI vs GUI) and adjust steps.

**Example outcome (`/experiment jdk-24 "Install JDK 24"`)**

`zshrc`:
```bash
## [exp] 2025-08-27: jdk-24: Install JDK 24
brew install --quiet openjdk@24
export PATH="/opt/homebrew/opt/openjdk@24/bin:$PATH"
## /[exp]
```

`apply.md`:
```markdown
## [exp] 2025-08-27: jdk-24: Install JDK 24
- move openjdk@24 to nix-darwin configuration
- add java environment variables to shell configuration
```

`rollback.md` (with verification):

```markdown
## [exp] 2025-08-27: jdk-24: Install JDK 24

### Rollback steps
brew uninstall openjdk@24
brew cleanup

### Verify
> java --version
zsh: command not found: java
```

---

### `/apply <experiment-name>` — make the experiment permanent

Promotes the trial into nix-darwin, removes the fence from `zshrc`, moves docs to **Applied**, rebuilds, and re-checks.

**What it does**
1) Find the experiment block in `zshrc` by its name.
2) Find the matching `apply.md` section.
3) Depending on what the experiment installs/configures, update the right nix files:
   - **brew packages** → `nix/homebrew.nix`
   - **system packages** → `nix/system-packages.nix`
   - **shell configuration** (env vars, etc.) → `nix/shell.nix`
4) Remove the fenced section from `zshrc`.
5) Move the section in `apply.md` to **Applied experiments**.
6) Rebuild nix-darwin.
7) Verify the tool is still available.

**Implementation notes**
- Check that the experiment exists before applying.
- Infer which bucket (brew/system/shell) it belongs to.
- Always rebuild after changes.
- Keep clear feedback about what changed.
- **Do not delete `rollback.md`** entries—leave the escape hatch.

**Example outcome (`/apply jdk-24`)**

Remove from `zshrc`:
```bash
## [exp] 2025-08-27: jdk-24: Install JDK 24
brew install --quiet openjdk@24
export PATH="/opt/homebrew/opt/openjdk@24/bin:$PATH"
## /[exp]
```

Add to `nix/homebrew.nix`:
```nix
"openjdk@24"
```

If needed, add env to `nix/shell.nix`:
```nix
environment.variables = {
  JAVA_HOME = "${pkgs.openjdk24}/libexec/openjdk.jdk/Contents/Home";
};
```

Promote the `apply.md` entry into “Applied experiments”, then rebuild:
```bash
cd ../nix-darwin-config
./rebuild.sh
```

Verify:
```bash
java --version
which java
```

---

### `/rollback <experiment-name>` — remove the change completely

Handles both cases: still experimental in `zshrc`, or already applied to nix-darwin.

**What it does**
1) Locate the experiment in `zshrc` **or** detect if it was applied in nix-darwin.
2) Load the matching `rollback.md` entry.
3) Execute the rollback:
   - **Experimental**: remove from `zshrc`, then run the uninstall commands.
   - **Applied**: remove from the appropriate nix files and rebuild.
4) Verify the tool is gone.
5) Optionally archive or remove the docs in `apply.md`/`rollback.md`.

**Implementation notes**
- Check both `zshrc` and nix-darwin to detect state.
- Always run `brew cleanup` after brew uninstalls.
- Always rebuild after nix-darwin edits.
- Provide clear feedback.
- Ask whether to keep the docs for future reference.
- Handle partial application—don’t leave dangling PATHs or env vars.

**Example outcome (`/rollback jdk-24`)**

**Case 1 — still in `zshrc`:**
```bash
# Remove fenced block from zshrc (same as the one shown earlier)

# Uninstall as per rollback.md:
brew uninstall openjdk@24
brew cleanup

# Verify:
java --version  # expect "command not found"
```

**Case 2 — already applied to nix-darwin:**
```nix
# nix/homebrew.nix
# remove the line:
"openjdk@24"
```

```nix
# nix/shell.nix
# remove JAVA_HOME and related variables if set
```

```bash
# Rebuild and verify:
cd ../nix-darwin-config
./rebuild.sh
java --version  # expect "command not found"
which java      # expect no path
```

---

## The operating loop (how you actually use this)

1) **Create the experiment**
   ```text
   /experiment jdk-24 "Install JDK 24"
   ```
   Run with the fence in place for a day or two. Keep the trial close to the code that uses it.

2) **Decide**
   - If it’s a keeper, **apply**:
     ```text
     /apply jdk-24
     ```
     The command migrates to nix-darwin, removes the fence, promotes docs, rebuilds, and verifies.
   - If it’s not, **rollback**:
     ```text
     /rollback jdk-24
     ```
     The command uninstalls/undoes and proves the tool is gone.

3) **Move on**
   - Applied experiments get tracked under “Applied experiments” in `apply.md`.
   - `rollback.md` retains every escape hatch so you can back out in the future.

---

## Conventions that make this safe

- **Deterministic fences**: always use `## [exp]` / `## /[exp]` with date, name, description.
- **Verification is mandatory**: every rollback includes a command that **must fail** (e.g., `java --version` → “command not found”).
- **One source of truth**: permanent steps live in `apply.md`, undo steps in `rollback.md`. Don’t bury instructions in random comments.
- **Nix first**: once proven, move installs/config to nix-darwin. Ad-hoc brew is for trials only.
- **Rebuilds are non-negotiable**: after any nix change, rebuild before you declare victory.

---

## Troubleshooting (preempt the foot-guns)

- **PATH weirdness after apply**
  You probably left a PATH export in `zshrc`. Remove it in `/apply`, and set env in `nix/shell.nix` if the tool requires it.

- **Ghost binaries after rollback**
  You uninstalled but didn’t verify. Run the **Verify** commands exactly as written; add `which <tool>` to flush out symlinks.

- **“Half-applied” state**
  The experiment had both brew and nix changes. Normalize: uninstall via brew, then ensure nix files are cleaned and rebuilt. Re-run Verify.

- **Confused about where to add a thing**
  Rule of thumb:
  - Third-party app/CLI via Homebrew → `nix/homebrew.nix`
  - System-level package via nixpkgs → `nix/system-packages.nix`
  - Env/aliases/shell tweaks → `nix/shell.nix`

---

## Why this works

- **Fast feedback**: experiments are just fenced bash in `zshrc`.
- **Reproducibility**: winners are promoted to nix-darwin in the right file.
- **Recoverability**: rollbacks are scripted and verified, not vibes-based.
- **Auditability**: every change has a date, name, apply steps, and a proven escape hatch.

Tinker boldly. If an experiment can’t be rolled back in under five minutes with a passing Verify, it doesn’t ship.
