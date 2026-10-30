# Foreign to All — Understanding, revision 6

141.5 seconds · 1920 × 1080 · 30 fps · stereo, mastered to −14 LUFS / −1 dBTP.

Revision 6 keeps revision 5's idea and storyboard: *sonder*, the crash, unfamiliar words, Brot, the notebook, asking for it, London's "You alright?", tea in Istanbul, Tanabata in Tokyo, the stereotype torn off, eight cities, the invitation, fireworks and the title. Everything you see and hear in it is rebuilt from the game as it is now.

- **Pictures.** The plates are the game's own scene art: the new orbit, the Berlin descent and the Kiez from the cinematic opening, plus Mitte, Karaköy, Asakusa, the London terrace and one street from each of eight cities. The title card uses the title-screen art.
- **People and items.** The game's renderer draws the people and objects. `tools/export_trailer_cast.gd` runs `CharacterArt` and `ItemArt` and saves 24-frame strips for every lead, the alien and four crowd extras.
- **Speech.** Glyph speech uses the dialogue box's runes, and a word decodes into amber when it is understood, as in the game.
- **Voices.** Each character speaks with the game's own ElevenLabs voice. Lukas, Arda, Setsuko and the Berlin crowd reuse their recorded lines. Nadia's three lines were made with her designed voice.
- **Score.** A new instrumental (Suno, "FtA Trailer v6 B") was chosen for its arc: a sparse opening, a long build, a breath at 92 s, a climax and a drop into the title at 121 s. Every scene starts on one of its downbeats (131.25 BPM; bar 1.8286 s, first downbeat 0.577 s).
- **Sound effects.** Synthesised to match each cue. The crash is the game's own.

## Timeline

| Time | Scene |
|---|---|
| 0:00–0:09.7 | *sonder* types out, the music already under it; a shutter cuts to black |
| 0:11.6–0:24.4 | Orbit → Berlin at dusk → the crash in the Kiez at dawn |
| 0:24.4–0:31.7 | Mitte: unfamiliar words, unwritten rules |
| 0:31.7–0:44.5 | Lukas: *Brot* decodes; rack focus into the notebook |
| 0:44.5–0:50.0 | "Brot, bitte?" — the bread, and Lukas's reputation card |
| 0:50.0–0:60.9 | London: "You alright?" — knowing the words is only the beginning |
| 0:60.9–1:08.2 | Istanbul: "Buyurun. Çay?" |
| 1:08.2–1:15.6 | Tokyo: Tanabata, a wish tied to the bamboo |
| 1:15.6–1:24.7 | A STRANGER tag stamped on Setsuko, torn off; her work, traditions and kindness |
| 1:24.7–1:32.0 | Eight leads in eight cities, one per bar |
| 1:32.0–1:39.3 | The breath: Nadia, "Coming? I saved you a spot." |
| 1:39.3–2:01.3 | Fireworks over the rooftops, cut to the score's climax |
| 2:01.3–2:21.5 | White bloom into the title; *stranger* in the game's 14 languages |

## Build

From the repository root. Run Python **without** the disposable Godot `APPDATA`; numpy lives in the user profile.

```powershell
# 1. cast strips and items, from the game's renderer (graphical Godot, disposable profile)
$env:APPDATA = "$env:LOCALAPPDATA\Temp\fta-render-profile"
godot --path . --script res://tools/export_trailer_cast.gd
Remove-Item Env:APPDATA

# 2. plates, fonts, the mixed and mastered soundtrack, and generated.json
python trailer/src/understanding-v6/build_audio.py

# 3. check and render, from trailer/
node node_modules/typescript/bin/tsc --noEmit
npx remotion render UnderstandingV6 out/foreign-to-all-understanding-v6.mp4 --codec=h264 --crf=16 --jpeg-quality=95 --concurrency=12 --audio-codec=aac --audio-bitrate=320k
```

`timeline.json` is the only place times live. Scenes, voice cues, sound cues, firework beats and loudness targets are all there. `build_audio.py` reads it and writes three things:
- `public/v6/mix.wav`;
- the gitignored copies of the plates and fonts in `public/v6/`;
- `generated.json`, which holds the typing schedule, measured voice lengths and the seeded firework bursts. The picture reads these, so sound and image cannot drift apart.

## Files

- `Film.tsx`: composition `UnderstandingV6`. It sequences the scenes and adds the light leaks, dips, grain and soundtrack.
- `lib/core.tsx`: shared pieces:
  - time helpers and type;
  - the `World` camera over a plate, and `Person` and `Item` from the exported strips;
  - glyph `Rune`s, speech `Bubble`s, `Caption`s and `Chyron`s.
- `lib/fx.tsx`: fireworks and the sky light they cast, smoke, stars, the pod's streak, Tanabata, the notebook card, the reputation card and the light leak.
- `scenes/`:
  - `Opening` (*sonder*, arrival);
  - `Berlin` (Mitte, Brot, notebook, bitte);
  - `Journey` (London, Istanbul, Tokyo);
  - `Turn` (stereotype, cities);
  - `Finale` (invitation, fireworks, title).

## Credits

Score: original instrumental generated with Suno for this trailer. Voices: the game's ElevenLabs character voices. Keyboard source: [mechanical key soft.wav by bigmonmulgrew](https://freesound.org/people/bigmonmulgrew/sounds/378083/), CC0. Camera shutter source: [Camera Shutter by roachpowder](https://freesound.org/people/roachpowder/sounds/170229/), CC0. Both recordings were edited for the mix. Title-script fonts: Noto Sans JP, KR, Devanagari and Georgian (SIL OFL 1.1), as shipped with the game.
