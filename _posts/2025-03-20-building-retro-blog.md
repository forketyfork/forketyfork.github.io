---
layout: post
title: "Building a Retro-Styled Blog with Modern Tech"
date: 2025-03-20
tags: [CSS, RetroStyle, WebDev]
---

Exploring how to create an 80s aesthetic using modern CSS features. Learn about CRT effects, scanlines, and text-glow animations.

## The CRT Effect

The CRT (Cathode Ray Tube) effect is achieved using a combination of CSS animations and pseudo-elements. Here's how we did it:

```css
.crt {
    animation: textShadow 1.6s infinite;
}

.scanline {
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background: linear-gradient(
        to bottom,
        transparent 50%,
        rgba(0, 0, 0, 0.1) 51%
    );
    background-size: 100% 4px;
}
```

## Modern Features Used

1. CSS Animations
2. Linear Gradients
3. Text Shadow Effects
4. CSS Variables

Stay tuned for more posts about retro web development!
