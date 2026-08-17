# Medium diagrams

Two Reveal-mode slides (exact HTML/CSS, black/gold) for the factory follow-up post.

Geometry follows the talk slide: 5px gutters, 1px gold/dashed borders, text centered in cells, grid filling the frame under the title.

| File | Claim |
|------|--------|
| `slide-01-sdlc.html` → `sdlc-eras.png` | Tab / sync copilot / async factory across SPEC→OPERATE |
| `slide-02-how.html` → `how-why.png` | Linear handoff loop vs three eras of where context lives |

Preview: open `slide-01-sdlc.html` / `slide-02-how.html`, or `index.html` (Reveal). Re-render:

```bash
timeout 25 google-chrome --headless --disable-gpu --no-sandbox --hide-scrollbars \
  --user-data-dir=/tmp/chrome-slides \
  --window-size=1920,1080 --virtual-time-budget=4000 \
  --screenshot=docs/blog/slides/sdlc-eras.png \
  file://$PWD/docs/blog/slides/slide-01-sdlc.html
```
