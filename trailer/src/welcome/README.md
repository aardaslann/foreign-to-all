# Foreign to All — Welcome

50.4 seconds · 1080 × 1920 (`WelcomeTall`) and 1920 × 1080 (`WelcomeWide`) · 30 fps · −14.5 LUFS.

A kinetic-type social film of the trailer's message, in the motion language of a TikTok reference: paper and black hard cuts, pen strokes that draw themselves, an ink ball, red sparkle stars, typing cursors, glowing figures, objects that orbit and burst. It shows no gameplay. Everything on screen is the game's own: the dialogue box's eight pixel glyphs, its items, its people (as drawn for revision 7 by `tools/export_trailer_cast.gd`), its voices and its wordmark.

## The film

1. **You can't read this.** Giant glyphs on red, then on ruled paper ("Kannste dit lesen?"). They shrink to a small line that comes into focus as *welcome. we were expecting you.*, with "Willkommen!" and "On vous attendait." under it. Then, on black: *you just couldn't read it yet.*
2. **The question and the drop.** *so how do you understand someone when you don't share a single word?* On the beat drop the cities' things burst out of it under the alien's mint light.
3. **The answer.** The alien as warmth (a heat map of his own sprite): *you don't start with words.* "words." turns back into glyphs. *you start with* a ring of things, and an ink ball knocks through it.
4. **listen. notice. try.** Three hero cards with "Je vous écoute.", "Что заметили?" and "Buyurun. Çay?".
5. **The label.** *a label gives you one word.* The red pen scribbles out STRANGER and Setsuko lights up as her life orbits her: *but everyone carries a whole life.* ("Jeder kommt von irgendwo."). Then eight people, half a beat each, named with their cities: *as vivid as yours.* The last is the alien, in his own colours: "You · far from home".
6. **Foreign.** *you may still be foreign. but you can still* **understand.** (decoded from glyphs, circled). F·O·R·E·I·G·N a card at a time, the O a turning pixel Earth, the cast saying "foreign" in seven languages. The letters scatter, the red pen gathers them, and they snap into the wordmark. "stranger" cycles through the languages, then *A world to discover. People to understand.*

## Build

From the repository root. Python needs only numpy; FFmpeg must be on PATH. The cast strips and items come from revision 7's build (`trailer/public/v7/`, see `../understanding-v7/README.md`).

```powershell
# 1. paper, grain and the upscaled glyph atlas
python trailer/src/welcome/build_assets.py

# 2. the soundtrack: the music edit, the voices, the sound design, both mixes
python trailer/src/welcome/build_audio.py

# 3. check and render, from trailer/
node node_modules/typescript/bin/tsc --noEmit
npx remotion render WelcomeTall out/foreign-to-all-welcome-9x16.mp4 --codec=h264 --crf=16 --jpeg-quality=95 --concurrency=12 --audio-codec=aac --audio-bitrate=320k
npx remotion render WelcomeWide out/foreign-to-all-welcome-16x9.mp4 --codec=h264 --crf=16 --jpeg-quality=95 --concurrency=12 --audio-codec=aac --audio-bitrate=320k
# the same picture with voices and sound only, for laying a TikTok sound over it
npx remotion render WelcomeTall out/foreign-to-all-welcome-9x16-nomusic.mp4 --props='{"soundtrack":"nomusic"}' --codec=h264 --crf=16 --audio-codec=aac --audio-bitrate=320k
```

`timeline.json` holds every time as `bar:beat` on the music's grid (70.5 BPM, first downbeat 0.132 s): the cues, the voices, the music edit and the copy. The scenes and `build_audio.py` both read it. The sound design repeats a few typing speeds and offsets from the scenes; change both together.

The music is `.build/welcome/music/B1-25e36195.mp3`. It is not committed, so download it again from the Suno workspace if `.build` is gone. Another take needs its own `b0`, `beat` and segments.

## Credits

Music: "FtA Welcome B", an original track made for this film on the owner's Suno Premier plan (workspace "Foreign to All - Game Music", song `25e36195-0b16-4762-b945-359ef493dee6`). Voices: the game's ElevenLabs character voices. Keyboard and transition click: revision 7's CC0 samples (`../understanding-v7/sfx/`). All other sound is synthesised in `build_audio.py`. Type: Figtree and Silkscreen (SIL OFL 1.1, via Google Fonts); Noto Sans JP, KR, Devanagari and Georgian, as shipped with the game.
