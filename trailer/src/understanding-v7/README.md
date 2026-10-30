# Foreign to All — Understanding, revision 7

126 seconds · 1920 × 1080 · 30 fps · stereo, −16 LUFS.

Revision 7 is revision 5's film made with the game as it is now. Revision 6 rebuilt everything and lost what made revision 5 work: its quiet, its slow piano, its look. This one keeps revision 5's soul and changes the craft.

## Kept from revision 5

- **The opening.** The *sonder* card is revision 5's code: "[sohn-durr]", Georgia, the same keystrokes on the same frames. There is no music under it, only the soft keys. The shutter closes to two seconds of black, and a reversed piano breath rises out of the black into the first picture.
- **The score.** Revision 5's piano is the original instrument from `../connection/build_audio.py`, ported to numpy. It is the same D minor to F major progression, slowed to 80% as revisions 4 and 5 were. It is re-composed bar by bar for this cut:
  - it is sparse at the arrival and fills slowly through the cities;
  - it quietens under the stereotype and lifts when Setsuko's name appears;
  - it swells for the bench and resolves on a low F under the title.

  Every scene starts on one of its bars.
- **The look.** The letterbox, the Georgia captions with the same lines and their fade-and-rise, the small place labels, the square pixel speech boxes with their stepped tails, the journal, and the person-not-label reveal with its three cards.
- **The ending.** The alien and Nadia sit on a bench with their backs to us, a cup steaming between them, watching pixel fireworks over the city. The pixel wordmark comes over them.

## New since revision 5

- **The game's art.** These are the game's own retro scene plates, the ones it actually draws (`*-retro.png`, listed in `art/environments/*-gameplay.json`): Mitte, the London high street and terrace, Karaköy, Asakusa, and one street in each of eight cities. The arrival uses the cinematic opening's orbit and Berlin rooftops, then the Kiez. The ending's sky is the title art.
- **The game's people.** They are drawn by the game's own renderer through `tools/export_trailer_cast.gd`. The back views on the bench use the same palette idea as revision 5: the face takes the colour of the back of the head.
- **The game's voices.** Lukas, Arda, Setsuko and the Berlin crowd speak their recorded lines; Nadia speaks hers. The alien has no voice, so his words type out on the same soft keys as the opening.
- **The game's glyphs.** Unread words are the dialogue box's own glyphs. *Brot*, *Çay* and *Tanabata* come into focus as gold letters when understood.
- **Small story beats.** Tanabata ends with a bow returned. Lukas answers "Bitte!". The stranger word cycles under the title as on the title screen.

An alternative mix, with a new Suno take in place of the piano (`.build/trailer-v7/music/`), can be built for comparison:

```powershell
python trailer/src/understanding-v7/build_audio.py --alt .build/trailer-v7/music/A-f970.mp3 --skip 12.4
```

## Build

From the repository root. Python needs only numpy; FFmpeg must be on PATH.

```powershell
# 1. cast strips (and back views), from the game's renderer: graphical Godot, disposable profile
$env:APPDATA = "$env:LOCALAPPDATA\Temp\fta-render-profile"
& "$env:USERPROFILE\Downloads\Godot_v4.7.2-stable_win64.exe" --path . --script res://tools/export_trailer_cast.gd
Remove-Item Env:APPDATA

# 2. plates, fonts, the score, the mix and generated.json (about seven minutes: the piano is synthesised note by note)
python trailer/src/understanding-v7/build_audio.py

# 3. check and render, from trailer/
node node_modules/typescript/bin/tsc --noEmit
npx remotion render UnderstandingV7 out/foreign-to-all-understanding-v7.mp4 --codec=h264 --crf=16 --jpeg-quality=95 --concurrency=12 --audio-codec=aac --audio-bitrate=320k
```

`timeline.json` holds every time:
- scenes, captions, voice and typing cues, sound cues;
- the firework beats;
- the score's chords, dynamics and melody.

`build_audio.py` writes `generated.json` (voice lengths, keystroke times, bursts), so picture and sound can't drift apart.

## Credits

Score: revision 5's original procedural piano, re-composed. Voices: the game's ElevenLabs character voices. Keyboard: [mechanical key soft.wav by bigmonmulgrew](https://freesound.org/people/bigmonmulgrew/sounds/378083/), CC0. Shutter: [Camera Shutter by roachpowder](https://freesound.org/people/roachpowder/sounds/170229/), CC0, as revision 4 prepared it. Title-script fonts: Noto Sans JP, KR, Devanagari, Georgian (SIL OFL 1.1), as shipped with the game.
