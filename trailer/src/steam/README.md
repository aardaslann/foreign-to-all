# Steam page media

Everything on the Steam store page that is a picture or a moving picture,
built from the game itself. The copy lives in `docs/steam/page/`; the local
preview renders that copy, so the two cannot drift.

| File | Makes |
| --- | --- |
| `KeyArt.tsx` | The key art scene (the intro's rooftop plate, the alien's back-view sprite, glyph speech boxes, the wordmark) and its re-crop for any size |
| `Capsules.tsx` | Header, small, main and vertical capsules, library capsule, hero, logo and page background as Remotion stills |
| `Hero.tsx` | The About banner: greetings in the eight languages resolving from glyphs |
| `Gameplay.tsx` | The 60-second gameplay trailer, cut on the bar to the title theme |
| `Steam.tsx` | Registers all of the above (imported by `../Root.tsx`) |
| `build_media.py` | Screenshots, About loops (GIF, WebM, posters), community icon, trailer loudness and the preview page |
| `preview.html` | The preview template (Steam layout, art placements, paste-ready copy, design notes) |

## Rebuild from scratch

Run from the project root. Godot writes 1920x1080 frames from the real game.

```sh
G="C:/Users/Arda/Downloads/Godot_v4.7.2-stable_win64.exe/Godot_v4.7.2-stable_win64_console.exe"
# 1. word-discovery screenshots (Berlin chapters 1-2, current source)
"$G" --path . --resolution 1920x1080 --script res://tools/steam_discovery_capture.gd -- "$PWD/.build/steam-capture/out"
# 2. real-time footage: Berlin chapter 1 and a walk through each city
"$G" --path . --resolution 1920x1080 --write-movie .build/steam-capture/film/berlin.avi --fixed-fps 30 \
  --script res://tools/steam_film_capture.gd -- berlin
"$G" --path . --resolution 1920x1080 --write-movie .build/steam-capture/film/tokyo.avi --fixed-fps 30 \
  --script res://tools/steam_film_capture.gd -- walk res://scenes/world/TokyoUeno.tscn 13.5 6.5 300 1
#    (mumbai MumbaiBhuleshwar 10, istanbul IstanbulHan 17.5, paris ParisMarais 8.5,
#     mexico MexicoCoyoacan 22.5, moscow MoscowBasmanny 12, london LondonTerrace 19)
# 3. transcode for Remotion
for n in berlin tokyo mumbai istanbul paris mexico moscow london; do
  ffmpeg -i .build/steam-capture/film/$n.avi -c:v libx264 -crf 14 -pix_fmt yuv420p trailer/public/steam/film/$n.mp4
done
# 4. art and trailer (from trailer/)
npx remotion still src/index.ts SteamHeader out/steam-page/assets/header_capsule_920x430.png   # and the other stills
npx remotion render src/index.ts SteamAboutHero out/steam-page/assets/about/hero.mp4
npx remotion render src/index.ts SteamGameplayTrailer out/steam-page/assets/trailer_gameplay_1080p.mp4
# 5. screenshots, loops, icon, loudness, preview
python trailer/src/steam/build_media.py
```

`trailer/public/steam/` also needs `wordmark-heavy.png` (the wordmark dilated
one pixel right and down: `ffmpeg -i art/world/ui/wordmark.png -vf
"format=gbrap,dilation=coordinates=11,format=rgba"`), `glyph-earth.png` (the
TikTok avatar), `music/title.ogg` (from `audio/music/`) and
`shots/field-notes.png`. The plates and cast come from `public/v7/`, which the
v7 trailer's export already provides.

## Rules this follows

- Every moving picture of the game is the game: movie-writer frames at real
  pace, never a mock-up. Key art uses only game art.
- Capsules carry the title and nothing else (Valve's rule).
- About loops stay inside Steam's 5 MB per image and 15 MB per section.
- The trailer's three title cards are the only added text; they decode from
  the dialogue box's glyphs, as the game does.
