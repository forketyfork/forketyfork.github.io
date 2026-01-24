---
layout: post
title: "compose-ui-test-server: Let AI Agents Click Through Your Desktop App"
date: 2026-01-24
tags: [AI, Agentic coding, Claude Code, Kotlin, Compose Desktop]
---

If you've ever used Claude Code or Cursor to debug a Compose Desktop app, you know the drill: run the app, take a screenshot, paste it into the chat, describe what you see, get a suggestion, try it, take another screenshot, paste it again. Repeat until fixed. It works, but it's tedious.

I got tired of being the middleman. So I built [compose-ui-test-server](https://github.com/forketyfork/compose-ui-test-server), a library that lets AI agents control your Compose Desktop app directly via HTTP. Now I just tell Claude Code to "debug why the form layout broke," and it runs the app, clicks around, takes screenshots, and figures things out on its own. I mostly just watch.

## Demo: from zero to agent-controlled app

Let me walk through the whole flow. Start with a fresh project from the [Kotlin Multiplatform Wizard](https://kmp.jetbrains.com/?desktop=true&includeTests=true) with Desktop selected:

![KMP Wizard with Desktop selected](/img/compose-ui-test-server/01-kmp-wizard.png){: .post-image }

Open the project folder in Claude Code:

![Running Claude Code on the project](/img/compose-ui-test-server/02-claude-code.png){: .post-image }

Install the skill so Claude knows how to use the library:

![Installing the compose-ui-control skill](/img/compose-ui-test-server/03-install-skill.png){: .post-image }

Ask Claude to set up the project with compose-ui-test-server. It adds the dependency and swaps the launcher:

![Claude setting up the project](/img/compose-ui-test-server/04-setup-project.png){: .post-image }

Now the fun part. Ask Claude to run the app, click the button, and save a screenshot:

![Claude clicking the button and capturing a screenshot](/img/compose-ui-test-server/05-click-button.png){: .post-image }

Claude runs the app with the test server enabled, finds the button, clicks it, and captures the result. No manual screenshots, no copy-pasting.

## How it works

The library wraps the Compose UI testing framework in a simple HTTP API. When enabled, your app starts an embedded server. Agents can click buttons by test tag or text, enter text into fields, wait for elements to appear, and grab screenshots. All through curl:

```bash
# Click a button
curl http://localhost:54345/onNodeWithTag/submit_button/performClick

# Enter text
curl "http://localhost:54345/onNodeWithTag/username/performTextInput?text=myuser"

# Wait for an element
curl "http://localhost:54345/waitUntilExactlyOneExists/tag/dashboard?timeout=5000"

# Take a screenshot
curl "http://localhost:54345/captureScreenshot?path=/tmp/current_state.png"
```

## Quick setup

Add the dependency to your desktop source set:

```kotlin
kotlin {
    sourceSets {
        val desktopMain by getting {
            dependencies {
                implementation("io.github.forketyfork:compose-ui-test-server:0.2.0")
                @OptIn(org.jetbrains.compose.ExperimentalComposeLibrary::class)
                implementation(compose.uiTest)
            }
        }
    }
}
```

Replace your `main()` function:

```kotlin
import io.github.forketyfork.composeuittest.WindowConfig
import io.github.forketyfork.composeuittest.runApplication

fun main() =
    runApplication(
        windowConfig = WindowConfig(
            title = "My App",
            minimumWidth = 1024,
            minimumHeight = 768,
        ),
    ) {
        App()
    }
```

That's it. The app runs normally by default. To enable agent control:

```bash
COMPOSE_UI_TEST_SERVER_ENABLED=true ./gradlew run
```

## Teaching Claude Code

The library includes a [SKILL.md](https://github.com/forketyfork/compose-ui-test-server/blob/main/SKILL.md) file that teaches Claude Code how to use it. Install it globally:

```bash
mkdir -p ~/.claude/skills/compose-ui-control
curl -o ~/.claude/skills/compose-ui-control/SKILL.md \
  https://raw.githubusercontent.com/forketyfork/compose-ui-test-server/main/SKILL.md
```

Or per-project:

```bash
mkdir -p .claude/skills/compose-ui-control
curl -o .claude/skills/compose-ui-control/SKILL.md \
  https://raw.githubusercontent.com/forketyfork/compose-ui-test-server/main/SKILL.md
```

Once installed, you can ask Claude Code things like "click the login button" or "take a screenshot of the current state." The skill also teaches it how to set up new projects with agent control from scratch.

## Making elements findable

For agents to interact with specific UI elements, add test tags:

```kotlin
Button(
    onClick = { /* ... */ },
    modifier = Modifier.testTag("login_button")
) {
    Text("Login")
}
```

Elements can also be found by their display text, but test tags are more reliable and won't break when you change labels.

## Why HTTP?

The Compose UI testing framework is designed for JVM tests running in the same process as the app. That's fine for automated tests, but useless for external tools. HTTP lets AI agents, shell scripts, or whatever else drive the UI without touching Kotlin or the testing framework internals.

The trade-off: you need to add a dependency and swap the launcher. But once that's done, anything that can make HTTP requests can control your app.

## Links

- GitHub: [forketyfork/compose-ui-test-server](https://github.com/forketyfork/compose-ui-test-server)
- Maven Central: [io.github.forketyfork:compose-ui-test-server](https://central.sonatype.com/artifact/io.github.forketyfork/compose-ui-test-server)

If you try it out, I'd love to hear how it goes.
