# Foreign to All — Understanding, revision 3

116 seconds · 1920 × 1080 · 30 fps · stereo audio.

This cut restores the original advertisement's emphasis on cultural context and seeing beyond stereotypes. A short language encounter leads into a misunderstanding, tea as a welcome, participation in Tanabata, and a sequence revealing the person behind a label. The ending keeps the shared fireworks and changes the line to “But you can still understand.”

The eight accented character recordings are retained. There is no narrator. Earlier exports remain in `trailer/out`.

## Opening

Both “sonder” and the user's exact full definition type character by character, using a deterministic keystroke schedule. The definition finishes at 7.3 seconds, then holds. A dry click lands on the hard cut to pure black at 12.5 seconds. The screen stays blank for 1.5 seconds. Story and music start together at 14 seconds.

## Culture and reference

The original `foreign-to-all.mp4` and `src/Pitch.tsx` supplied the key ideas: words are only part of communication; meaning needs context; a stereotype discards a person's complexity; understanding grows through experience.

The Tanabata paper-wish exchange and Setsuko's story come from `scenes/npc/KeyLines.gd` (Tokyo holiday sequence). Her kitchenware shop is established in `autoload/Story.gd`. The customs shown belong to these staged character encounters; the ad does not claim every person in a city behaves identically.

## Character repair

`actorGeometry.ts` keeps the original eye sockets intact instead of using exported gaze variants that move the white pixels independently. Blinking closes whites and pupils together. The collar stays attached to the coat, and a short join fills the neck when the head lifts. Head dips are bounded; lowering the head overlaps the coat without opening a seam. The actual game files are not changed.

`check_motion.cjs` verifies head-to-body connectivity and eye geometry across 69,120 character/pose/frame combinations. `CastReview.tsx` provides a separate animated contact sheet for visual inspection.

## Render

From the `trailer` folder:

```powershell
node node_modules/typescript/bin/tsc --noEmit
node src/connection-v3/check_motion.cjs
node node_modules/@remotion/cli/remotion-cli.js render src/connection-v3/index.tsx ConnectionV3 out/foreign-to-all-understanding-v3.mp4 --codec=h264 --pixel-format=yuv420p --crf=17 --image-format=png --audio-bitrate=256k --concurrency=8
```

`Connection.tsx` holds staging; `timing.ts` holds reading windows. `build_remix.py` rebuilds audio from saved recordings using Python with numpy, scipy and soundfile plus FFmpeg. The soundtrack uses a measured fixed gain to preserve soft keystrokes rather than boost them dynamically. `public/connection-v3` contains the mix and separate stems.

## Timeline

| Time | Scene |
| --- | --- |
| 00:00–00:12.5 | Typed Sonder opening and reading hold |
| 00:12.5–00:14 | Click; black screen and pause |
| 00:14–00:25 | Arrival; unfamiliar words and unwritten rules |
| 00:25–00:37 | A word begins a conversation |
| 00:37–00:52 | Nadia; knowing the words is only the beginning |
| 00:52–01:01 | Tea as a welcome |
| 01:01–01:11 | Tanabata: a wish and the stories traditions carry |
| 01:11–01:23 | A label gives way to a person's work, traditions and kindness |
| 01:23–01:32 | Across cultures; let people change your assumptions |
| 01:32–01:38 | Nadia's invitation |
| 01:38–01:48 | Foreign, but able to understand |
| 01:48–01:56 | Title and scope |

## Credits

Game characters, palette and wordmark: Foreign to All project assets. Settings and animation: code-drawn for the trailer. Music: original procedural piano composition, retimed for the edit. Character voices: existing synthetic Conrad, Libby, Ryan and Ahmet recordings.

Keyboard source: [“mechanical key soft.wav” by bigmonmulgrew](https://freesound.org/people/bigmonmulgrew/sounds/378083/), [CC0](https://creativecommons.org/publicdomain/zero/1.0/). Saved recording edited, softly equalized and varied; the cut click is derived from the same recording.
