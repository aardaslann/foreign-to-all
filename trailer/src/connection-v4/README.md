# Foreign to All — Understanding, revision 4

121.5 seconds · 1920 × 1080 · 30 fps · stereo audio.

This revision restores the purple journal between hearing “Brot” and using “Brot, bitte?”. The word types into the journal, its meaning appears beneath it, and the following encounter supplies the payoff. All culture scenes, the sequence about stereotypes, the eight accented character lines, and the fireworks ending retain their previous durations. There is no narrator.

The full Sonder definition still types out and holds for reading. A recorded camera shutter, layered with a short original low impact, now cuts to black at 12.5 seconds. The black screen lasts two seconds. The click decays quickly, leaving silence before picture and music start together at 14.5 seconds. The opening's soft keyboard recording is unchanged and is not used for the transition snap.

The small background child has been removed from the scene with unfamiliar words. Character animation continues to use revision 3's repaired neck and eye geometry.

## Timeline

| Time | Scene |
| --- | --- |
| 00:00–00:12.5 | Typed Sonder opening and reading hold |
| 00:12.5–00:14.5 | Shutter impact; black screen |
| 00:14.5–00:25.5 | Arrival; unfamiliar words and unwritten rules |
| 00:25.5–00:32.5 | Hearing Brot |
| 00:32.5–00:37.5 | Brot enters the journal |
| 00:37.5–00:42.5 | Trying Brot, bitte? |
| 00:42.5–00:57.5 | Nadia; knowing the words is only the beginning |
| 00:57.5–01:06.5 | Tea as a welcome |
| 01:06.5–01:16.5 | Tanabata and the stories traditions carry |
| 01:16.5–01:28.5 | Seeing the person beyond a stereotype |
| 01:28.5–01:37.5 | Across cities and cultures |
| 01:37.5–01:43.5 | Nadia's invitation |
| 01:43.5–01:53.5 | Foreign, but able to understand |
| 01:53.5–02:01.5 | Title and scope |

## Build

From the trailer folder, run the audio builder with Python containing numpy, scipy and soundfile, with FFmpeg on PATH. The saved recordings are sufficient; no speech service is called.

```powershell
python src/connection-v4/build_remix.py
node node_modules/typescript/bin/tsc --noEmit
node node_modules/@remotion/cli/remotion-cli.js render src/connection-v4/index.tsx ConnectionV4 out/foreign-to-all-understanding-v4.mp4 --codec=h264 --pixel-format=yuv420p --crf=17 --image-format=png --audio-bitrate=256k --concurrency=8
```

The mix uses a measured fixed gain, preserving the difference between soft typing, the stronger transition, and dialogue. The original procedural score is retimed to accommodate the journal without shortening the culture scenes. Earlier exports are preserved.

## Credits

Characters, palette, wordmark: Foreign to All project assets. Settings and animation: code-drawn. Music and low impact: original procedural synthesis. Character voices: existing Conrad, Libby, Ryan and Ahmet recordings.

Keyboard source: [mechanical key soft.wav by bigmonmulgrew](https://freesound.org/people/bigmonmulgrew/sounds/378083/), CC0. Camera shutter source: [Camera Shutter by roachpowder](https://freesound.org/people/roachpowder/sounds/170229/), CC0. Both recordings were edited for the mix.
