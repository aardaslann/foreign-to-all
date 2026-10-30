# Opening artwork

Three bitmap resources for the opening's orbit and Berlin descent shots, added
on 2026-09-29. The Kiez ground shot reuses
`art/environments/scenes/Kiez-retro.png` unchanged, with the game's dawn tint.
Characters use the existing `CharacterArt` and `CastRoster` renderers.

## Images

- `orbit.png`: full-bleed detailed retro/pixel Earth in low orbit at night;
  curved Earth, dark teal land, amber city lights, silver-teal clouds, quiet
  upper sky, turquoise atmosphere and a restrained peach dawn edge. No ship,
  text, frames or interface.
- `berlin-rooftops.png`: ordinary Berlin railway neighbourhood before dawn;
  red-brick arches, plaster apartments, lit windows, catenary and trees;
  open upper sky for the falling pod. No people, spacecraft, text or landmarks.
  Its pixel style matches `Kiez-retro.png`.
- `pod-flight.png`: the existing Kiez pod, intact, in a three-quarter bank
  down and left; charcoal oval hull, dark metal plates, black ports and thin
  cyan seams. Transparent background; no ground, shadow, smoke or trail.
  The pod matches the one in `Kiez-retro.png`.

Runtime camera movement, tint, trail and smoke are drawn by `IntroStage.gd`; the
project's existing smoke strip is reused. No original game artwork was replaced.

## Sound

`audio/intro/arrival.wav` is original deterministic, non-musical synthesized
sound: pod hum, entry air, a subdued impact, gravel steps and cooling metal.
There are no sampled recordings, voices or music. Regenerate it using:

```powershell
$env:APPDATA = Join-Path $env:TEMP 'foreign-intro-review-profile'
& '<Godot console executable>' --headless --path . --script res://tools/build_intro_sound.gd
```

The shipped WAV is generated once, not on the player's loading path. Playback
uses the existing SFX bus and follows the opening's pause and skip controls.
