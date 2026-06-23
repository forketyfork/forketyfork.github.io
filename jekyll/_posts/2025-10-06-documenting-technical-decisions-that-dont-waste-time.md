---
layout: post
title: "Documenting Decisions for AI Agents, Not Humans"
date: 2025-10-06
tags: [Engineering, AI, Agentic Development, Documentation]
---

We're building a project where most code is written by AI agents. Not "AI-assisted" development where you write code and Copilot fills in the blanks. Actual agentic development where Claude Code makes architectural decisions, implements features, and iterates on designs.

The problem? Agents don't remember past decisions. Each conversation is a blank slate. Without a memory system, you get the same terrible suggestions over and over.

## The Problem: Agents Without Memory

Here's what happens when an agent has no decision history:

**Iteration 1:**
- Agent suggests using Server-Sent Events for real-time updates
- You discuss trade-offs, decide on WebSockets
- Agent implements WebSockets

**Iteration 2 (next day):**
- Different conversation context
- Agent sees real-time updates code
- "Hey, have you considered using Server-Sent Events?"
- You waste 10 minutes explaining why you already rejected this

**Iteration 3 (week later):**
- Agent working on a different feature
- Suggests refactoring to use SSE
- You scream into the void

The agent isn't being dumb. It legitimately doesn't know you've already had this conversation. It's reading the codebase, seeing a design choice, and suggesting alternatives — exactly what you'd want, except you already did this thought process.

## The Solution: Structured Memory for Agents

We created a decision registry specifically designed for agent consumption. Not documentation for humans that agents can read — documentation *for agents* that humans can also read.

Key insight: **Agents should write decision records, not just read them.**

Here's the workflow:

1. Agent encounters a design decision during implementation
2. Agent documents the decision in a structured format
3. Future agents read these records before suggesting changes
4. Records accumulate as the project grows
5. Agents build on past decisions instead of questioning them

Each decision lives in `docs/td/DR-NNN-brief-description.md` with a fixed structure:
- **Context**: The problem requiring a decision
- **Options Considered**: Alternatives with pros/cons
- **Decision**: What was chosen
- **Rationale**: Why this option won
- **Consequences**: Trade-offs accepted

## How Agents Actually Use This

### Reading Decisions

We added this to our codebase instructions:

> When making sense of unfamiliar code, list the `docs/td/` directory to check for relevant decision records. Reading related decisions helps understand the rationale behind current implementation choices.

Agents now start work by checking existing decisions. Working on authentication? Read `DR-003-single-github-app-installation-id.md` first. Adding UI features? Read `DR-004-multi-style-theming-system.md`.

This dramatically reduces back-and-forth. Instead of:

```
Agent: "Should we use CSS-in-JS or separate style files?"
You: "We already decided on separate files"
Agent: "Why?"
You: "Because CSS-in-JS bloats the bundle"
Agent: "What about runtime theming?"
You: [explains for 10 minutes]
```

You get:

```
Agent: [reads DR-004]
Agent: "I'll add the new style as a separate CSS file following the existing pattern"
You: "Yep"
```

### Writing Decisions

When an agent makes a significant technical choice during implementation, it documents the decision:

```
You: "Add dark mode support"

Agent: "I'll need to decide between CSS variables and CSS-in-JS for theming.
Let me document this decision...

[Creates DR-004 with context, options, and rationale]

I've chosen CSS variables because:
- Lower bundle size
- No runtime overhead
- Matches existing architecture

Implementing now..."
```

The decision record gets committed with the implementation code. Future agents inherit this knowledge.

## The Architecture That Makes This Work

### 1. Separate Files, Not a Monolithic Document

We initially tried a single `DECISION_REGISTRY.md` file. Terrible idea.

Agents load entire files into context. A monolithic file means every agent pays the context cost for every decision ever made. By decision #10, agents are burning tokens on decisions about Kubernetes pod labels when they're working on UI components.

Separate files let agents:
1. List the directory (minimal cost)
2. Filter by filename for relevance
3. Read only relevant decisions

When working on GitHub integration, the agent sees `DR-001-restore-github-cli-in-acp-proxy-container.md` and reads just that. Context cost: ~500 tokens instead of 5000.

### 2. Descriptive Filenames Are Agent-Facing UI

`DR-001.md` tells the agent nothing. `DR-001-restore-github-cli-in-acp-proxy-container.md` tells the agent this decision is about GitHub CLI in the ACP proxy container.

Agents filter decisions by filename before reading content. Good filenames mean agents read only what matters.

### 3. Structured Format Enables Agent Processing

The template has fixed sections. This isn't for aesthetics — it's so agents can parse decisions programmatically.

Agent sees:
```
**Options Considered**:
1. **Keep gh CLI removed**
   - Cons: Agents must use curl for GitHub API
2. **Restore gh CLI**
   - Pros: Better developer experience
   - Cons: 15MB larger container
```

Agent understands: "They considered removing gh CLI. Rejected because of poor UX. Don't suggest removing it."

Unstructured prose would force the agent to infer this from context, wasting tokens and introducing ambiguity.

### 4. Commit Decisions With Implementation

Decision records live in the same git commit as the implementation:

```
commit a3876eb
  Add dark mode support

  - Implement CSS variable theming
  - Create ThemeContext
  - Add theme toggle UI
  - Document decision in DR-004
```

This ensures:
- Agents see decisions when reading git history
- Decisions are documented while context is fresh
- Can't merge features without documenting why you built them that way

## When Agents Should Create Decision Records

We tell agents to document decisions that:
- Change core architecture or data flow
- Involve selecting between libraries or frameworks
- Have security or performance implications
- Affect deployment patterns
- Establish new development patterns

One-line bug fixes don't need decision records. Choosing between five WebSocket libraries does.

The agent makes this call during implementation. If it's weighing multiple approaches, it documents the choice.

## The Surprising Benefits

### 1. Agents Build On Each Other's Work

Early agent sessions establish patterns. Later agents follow them. We have agents writing CSS that matches the theming system another agent designed weeks ago, because they read DR-004 first.

This consistency is hard to achieve even with human teams. With agents, it's automatic if you give them structured memory.

### 2. Humans Learn the Codebase From Agent Docs

I often read our decision records to remember why we built something a certain way. The agent who implemented it documented the reasoning better than I would have in a PR description.

Decision records become onboarding docs for new humans and new agent sessions.

### 3. Design Debates Get Resolved Once

"Should we use SSE or WebSockets?" gets answered in DR-005. Every agent that touches real-time communication reads DR-005 first. The debate never happens again.

This is what documentation is supposed to do, but it only works if:
- Documentation is findable (separate files with descriptive names)
- Documentation is consumable (structured format agents can parse)
- Documentation is trustworthy (committed with implementation)

### 4. Context Costs Stay Linear, Not Exponential

Without decision records, context requirements grow exponentially. Each new feature requires explaining past decisions. By iteration 50, agents are spending half their context window on "why did we build it this way?"

With decision records, context costs grow linearly. Agents load only relevant decisions. A project with 100 decisions costs the same per-session as a project with 10, because agents only load 2-3 relevant ones.

## The Template

We keep the template in `docs/td/decision-template.md` with detailed instructions for agents. It includes examples and explains what to put in each section.

The full template and examples are in [our project's decision directory](https://github.com/forketyfork/acp-web/tree/main/docs/td).

## Bottom Line

If you're doing agentic development, you need structured memory. Agents without memory waste your time re-litigating decisions you've already made.

Decision records aren't documentation in the traditional sense. They're the agent's memory system. Design them for machine consumption first, human consumption second.

Keep them:
- **Structured**: Fixed format agents can parse
- **Distributed**: Separate files minimize context cost
- **Discoverable**: Descriptive filenames enable filtering
- **Committed**: In the same commit as implementation

And most importantly — let agents write them. They're better at documenting their own decisions than you are.
