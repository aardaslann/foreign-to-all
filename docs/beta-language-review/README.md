# Language and local review

The current speech pack contains **415 exact spoken lines** across all eight
staged city stories and their room/ticket counters. `spoken-lines.json` is the
authoring export; `review.csv` has a clip path for every line. **No line has been
signed off by a native reviewer.** Russian, Hindi and Japanese story speech uses
native-script readings rather than pronouncing the phonetic display.

Audio is provisional synthetic speech from the existing `edge-tts` pipeline.
It is not an actor recording. The manifest records its provenance. The beta also
includes 106 crowd fragments in German, Turkish, English, French and Mexican
Spanish, with two voices per fragment; the other three languages' crowd speech
still needs native readings. Speech quality and cultural context require review.

Review the spoken line together with its branch in `scenes/story/`, not in
isolation. The worksheet retains blank cells for the reviewer and corrections.

- Check idiomatic language, pronunciation and the character's intended tone.
- Check the gesture makes sense before meaning is revealed.
- Check a mistaken interpretation can be repaired without humiliating the player.
- Flag statements presented as rules for an entire culture, including optional
  district activities and existing dialogue outside these new story scripts.
- Review holiday context, family assumptions, dialect, forms of address and
  whether these individuals sound distinct from each other.
- Play the scene: confirm the audio, glyphs, characters and resulting action agree.

After accepting an edit, rerun `tools/export_beta_speech.gd`, then
`python tools/build_voices.py`, then `python tools/update_beta_review.py` and a Godot editor import. Exact-text keys prevent an edited line from
playing an obsolete recording. Regeneration is incremental. Preserve completed
human review notes when updating the worksheet.

For beta pacing, enable **Pause → Beta feedback → Keep local playtime notes**.
These are approximate active seconds, not proof that a city is enjoyable or
lasts twenty minutes. Ask testers to record where a meaning clicked, where an
instruction was unclear, and when they wanted to stop. The report is a local
file; the player chooses whether to share it.
