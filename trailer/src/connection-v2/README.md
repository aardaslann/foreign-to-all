# Foreign to All — A Place to Belong, revision 2

108 seconds · 1920 × 1080 · 30 fps · stereo audio.

This revision replaces voice-over with large story text, preserves all eight accented character recordings, extends the reading pauses, and stages the current game characters in newly drawn, minimal pixel-art settings. The opening uses the supplied full definition of Sonder and the game's native purple, lavender and gold palette. Its heading has seven quiet recorded keyboard events; the complete definition then holds for reading.

The first cut and original advertisement remain separate files in `trailer/out`.

## Render

From the `trailer` folder:

```powershell
node node_modules/typescript/bin/tsc --noEmit
node node_modules/@remotion/cli/remotion-cli.js render src/connection-v2/index.tsx ConnectionV2 out/foreign-to-all-a-place-to-belong-v2.mp4 --codec=h264 --pixel-format=yuv420p --crf=17 --image-format=png --audio-bitrate=256k --concurrency=8
```

- `Connection.tsx`: visual staging and animation.
- `timing.ts`: independent reading windows, exact definition, and heading key timing.
- `build_remix.py`: dialogue-only soundtrack, retimed music, environmental sound, and keyboard recording. Requires Python with numpy, scipy and soundfile, plus FFmpeg on PATH. Uses the saved character recordings; no new speech generation is needed.
- `public/connection-v2`: final soundtrack, separate dialogue/music/effects stems, and the timed character cues.
- `../connection/data.ts`: current game character grids and wardrobe from the first cut. The character voices and music originals also remain under `public/connection`.

## Credits

Game characters, palette and wordmark: Foreign to All project assets. New settings and animation: code-drawn for this advertisement. These are staged trailer scenes.

Music: original procedural piano composition from the first cut, slowed slightly without intentionally changing pitch. Character voices: the original synthetic Conrad, Libby, Ryan and Ahmet recordings. The narrator stem is excluded with an explicit dialogue allowlist.

Keyboard: [“mechanical key soft.wav” by bigmonmulgrew](https://freesound.org/people/bigmonmulgrew/sounds/378083/), released under [CC0](https://creativecommons.org/publicdomain/zero/1.0/). Source: Freesound's public high-quality MP3 preview. Edited, softly equalized and varied for seven keypresses.

## Reading and scene timing

| Time | Scene |
| --- | --- |
| 00:00–00:13 | Purple Sonder opening, full definition, pause |
| 00:13–00:26 | Arrival; unfamiliar voices |
| 00:26–00:44 | Hear Brot, remember it, ask for it |
| 00:44–00:53 | “You alright?” exchange |
| 00:53–01:02 | Words and their unspoken meaning |
| 01:02–01:09 | Tea and an invitation |
| 01:09–01:16 | Learn by living |
| 01:16–01:24 | Eight cities and their people |
| 01:24–01:30 | “I saved you a spot.” |
| 01:30–01:40 | Foreign, and no longer alone |
| 01:40–01:48 | Title and premise |
