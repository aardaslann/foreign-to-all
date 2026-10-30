# Foreign to All — A Place to Belong

A 95-second animated advertisement, 1920 × 1080 at 30 fps. Master: `out/foreign-to-all-a-place-to-belong.mp4`.

The film follows the stranded alien from hearing a first word, to trying it, to discovering that culture changes what words mean. Nadia's invitation pays off the earlier London misunderstanding. The short dictionary opening sets the emotional tone.

## Edit and render

Run from the `trailer` folder:

```powershell
node node_modules/typescript/bin/tsc --noEmit
node node_modules/@remotion/cli/remotion-cli.js render src/connection/index.tsx Connection out/foreign-to-all-a-place-to-belong.mp4 --codec=h264 --pixel-format=yuv420p --crf=17 --image-format=png --audio-bitrate=256k --concurrency=8
```

`Connection.tsx` contains the scenes and frame-based animation. `index.tsx` sets the resolution, frame rate, and duration. Dialogue and narration timings live in `public/connection/cues.json`. After changing those cues or exporting the cast, run `node src/connection/prepare.mjs` to update the composition data and SRT subtitles.

`build_audio.py` composes the piano score, synthesizes effects, generates the voices, and mixes a stereo soundtrack with music ducking. It requires Python with `numpy scipy soundfile edge-tts`, plus FFmpeg/ffprobe on PATH. Existing voice MP3s, score, and effects are reused; remove only the specific cached asset you intend to regenerate. Run `prepare.mjs` after rebuilding audio. Re-rendering the film uses the saved audio and requires no speech service.

## Assets and production

- Characters: native pixel grids, palettes, wardrobe, gaze, props, and pose offsets exported from the current `CharacterArt.gd`, `Cast.gd`, `CastRoster.gd`, and `Wardrobe.gd` with `export_cast.gd`.
- Environments: actual Godot background nodes from Kiez, Mitte, BerlinPrenzlberg, LondonTerrace, IstanbulHan, and TokyoUeno. `export_plates.gd` captures them through a real renderer; Godot's headless dummy renderer cannot capture these textures.
- Logo and ending backdrop: the project's existing `public/art/ui/wordmark.png` and `public/art/scenes/title.png`.
- Additional bench, stall, notebook, paper wishes, weather and fireworks: code-drawn animation. Night lighting and rear-view poses are adapted for the film. These are staged trailer scenes, not recorded gameplay.
- Music and effects: original procedural composition and sound design, with separate `score.wav` and `effects.wav` stems.
- Voices: synthetic Microsoft Edge voices — Sonia (narrator), Libby (Nadia), Conrad (Lukas and German alien lines), Ryan (English alien lines), Ahmet (Arda). Character voice choices are trailer production choices, not a claim about in-game voice acting.
- The film uses no generated painterly imagery. All saved assets needed to render are in the project.

## Timeline

| Time | Scene |
| --- | --- |
| 00:00–00:10 | Dictionary opening and a breath of silence |
| 00:10–00:23 | Crash site; unfamiliar Berlin voices |
| 00:23–00:40 | Brot: hear, record, try, receive |
| 00:40–00:56 | Nadia: “You alright?” and the meaning behind it |
| 00:56–01:03 | Arda's invitation over tea |
| 01:03–01:09 | Setsuko; attention and a small bow |
| 01:09–01:15 | Eight cities, eight people |
| 01:15–01:20 | Nadia saves a place |
| 01:20–01:35 | Shared fireworks; title and premise |
