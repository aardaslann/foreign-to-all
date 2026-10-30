# Trailer build notes

Working notes for the 95s promo film. Storyboard: `storyboard.html`.
Direction settled: **bolder graphic treatment**, no captured gameplay, built silent
to a timing sheet. Pipeline is Remotion (React/TS), 1920x1080 @ 30fps.

## Asset geometry — measured from the PNGs, not guessed

| Asset | Size | Layout |
|---|---|---|
| `scenes/*.png` (mitte, wreck, title, lobby) | **576 x 324** | full-screen plate |
| `npcs/*_sheet.png` (renate, lukas, commuter_f/m, weber, pigeon) | 192 x 128 | 32px cells · rows `down/up/right/left` · cols = idle x2, then walk x4 |
| `player/alien_sheet.png` | 256 x 416 | 32px cells → 8 cols x 13 rows |
| `player/strips/walk_*.png` | 256 x 32 | 8 frames @ 32px |
| `player/strips/idle_*.png` | 192 x 32 | 6 frames @ 32px |
| `tiles/tileset_*.png` | 224 x 16 | single row of 16x16 cells, 14 tiles (sidewalk→runner) |
| `ui/wordmark.png` | 240 x 84 | |
| `ui/glyphs.png` | 96 x 12 | |
| `ui/familiarity_pips.png` | 32 x 8 | 4 pips, tier 0-3 |

Animation rates the game uses: **idle @ 2fps, walk @ 8fps** (`WorldArt.npc_frames`).
In-game sprites are `centered = false`, `scale = (2,2)`, `TEXTURE_FILTER_NEAREST`,
and NPC/player rigs use `offset = Vector2(0, -1.5)` so feet land on the origin.

## Scaling — the one thing to get right

576 x 324 into 1920 x 1080 is **x3.333, a non-integer scale** — that shimmers and
softens pixel art. Work at **x3 (1728 x 972)** and compose within the 1080 frame,
or x4 (2304 x 1296) and crop. Never x3.333. Every raster layer needs
`image-rendering: pixelated` and integer-pixel transforms.

## Colour — copy, don't eyeball

Palettes are real files: `art/world/foreigntoall_world.gpl`, `art/player/alien.gpl`.
Dialogue tiers from `scenes/dialogue/DialogueBox.gd:496-511`:

| Tier | Colour |
|---|---|
| UNKNOWN | `#e8e4ff` |
| GLIMPSED | `#b8b4f0` |
| PARTIAL | `#d8d4ff` on `#35359a` |
| KNOWN | `#f0eeff` |

Glyph set `◈⟟⬡◉⟢⟣⋄⟤⟥⬢⬣⬟⬠⟦⟧⟡`, mapped `G[codePoint % 16]`, shuffled every **0.18s**
for first-time words. Font is Godot's default = **Open Sans** (Google Fonts).

## Not yet built
No London or İstanbul art exists anywhere in the project. Both acts must be
composed from scratch against `docs/design/london.md` §1-2 and
`docs/design/istanbul.md` §1-2.
