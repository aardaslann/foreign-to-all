# Eight-city beta implementation

Updated 2026-10-04. Work is installed in `C:/Users/Arda/Projects/foreigntoall`.
The beta is still in development; this is not a release sign-off.

## Latest Source Review

2026-10-04 desktop expansion: Linux/Mac candidate `20261004.6` passes native
headless and graphical release startup on Ubuntu 24.04 x86_64 and macOS 15.7.9
Intel/Apple Silicon. Each passes 2,457 exported-data checks plus 20 packaging
safeguards. Windows `20261004.4` and gameplay are unchanged. The Mac ZIP is a
clearly labelled ad-hoc-signed private-test build, not Developer ID signed or
notarized. Downloaded-app security, physical audio/controllers and human playtime
are not certified. See `docs/desktop-native-results-20261004.6.md` and
`docs/desktop-distribution.md` for exact hashes, native/editor-host distinctions,
private downloads and reproducible packaging.

2026-10-04 clarification: small-word hints no longer expose spelling before the
normal familiarity threshold. Every readable word keeps a separate lavender
hover box, including fully known and confirmed words; amber/gold letters keep
their meaning. English and deliberate teaching targets retain their existing
readability rules. The earlier dialect and sentence-context work is preserved.
66 graphical word, 25 notebook, 102 feedback UI and 36 context checks pass.
Build `20261004.3` passes 66 word checks and 148 graphical smoke checks against
exported data; standalone release startup exits 0.
See `Foreign to All/decisions/2026-10-04-glyphs-and-word-hover-boxes.md`.

2026-10-04 player-feedback pass: common connecting words have tentative meanings;
new discoveries open an untimed contextual reflection with an optional written
guess, explicit meaning, pronunciation and a saved notebook reading. Confirmed
knowledge and familiarity remain separate. Meeting and outing quests use the
actual in-game line/stop data and switch to local landmarks on arrival. All eight
celebrations now use dedicated pixel-art cinematic scenes with the customised
alien and local cast; no new walkable districts or collision changes.
New feedback checks: 71; graphical discovery/arrival/event checks: 101; notebook:
25; all eight city-story suites pass. Build `20261004.2` passes those same 71 + 101
feedback checks against exported data, 148 packaged smoke checks and standalone
startup (exit 0). Details and limitations:
`Foreign to All/decisions/2026-10-04-player-feedback-learning-and-celebrations.md`.

2026-10-04: both independent follow-up findings are also fixed and packaged.
Returning early from an unfinished city gets a fresh onward leg without changing
its story progress; active legs retain a local airport target. Older saves in
the finale field reconcile without an extra visit, and receiving a name closes
all ending steps. New regression: 51 checks (21 failed before the fix), also
passing against exported data. Package smoke: 148 graphical checks; native
startup: exit 0. See `Foreign to All/decisions/2026-10-04-guidance-edge-fixes.md`.

2026-10-03: the eight local stories and the naming finale are implemented, and
the eight core cities have no required travel order after the Berlin opening.
The final review's three guidance issues are fixed: the onward quest lists every
unfinished city and aims at the local airport, the finale leads home through the
local airport to the Kiez, and the ending outranks optional jobs in the tracker.
See `docs/beta-readiness-review-2026-10-03.md` and
`Foreign to All/decisions/2026-10-03-open-journey-guidance.md`.

The user-requested red quest arrow is now opt-in: G / right-stick press toggles
it, with a binding-aware state hint beneath the tracker. Tab/M remain the map.
The preference persists in settings and is not reset by doors or quest updates;
dialogue, stories and menus suppress the arrow. The gold job marker is unchanged.
It ships in `20261003.2`; `20261003.1` still has the old automatic arrow.
See `Foreign to All/decisions/2026-10-03-player-controlled-quest-arrow.md`.

## Current Candidate

Windows `0.2.1-beta.1`, build `20261004.4` (supersedes `20261004.3`; adds the eight-city small-word hints), is packaged under `build/`
with embedded game data, player guide, credits, third-party notices and a checksum
manifest. Runtime source: `add8faf`; no uncommitted runtime files. It includes the
player-feedback changes above, the scene-backed map atlas and the beta review's ten fixes: word-use
encounters in all eight cities, pronunciation in all eight languages, clearer notebook
evidence, per-city pacing and the staged naming (`Foreign to All/decisions/2026-10-02-beta-review-fixes.md`). Controls persist across restart; save failure/corruption handling,
overwrite/delete confirmation and refreshed Continue/Settings/feedback are in.
English is the complete beta UI; other selectable translations are previews.
The `.2` patch updates credits at the user's request and retains engine/font notices;
it changes no gameplay. Focused graphical UI checks: 127; packaged-data smoke: 128;
native release startup: exit 0. See `Foreign to All/decisions/2026-10-02-credits-update.md`.
The `.3` patch adds a 7.6-second skippable plane flight between city selection and
arrival, with pause, reduced motion and arrival checkpoints. Flight checks: 90;
uninterrupted flight: 4; packaged-data smoke: 135; native startup: exit 0. See
`Foreign to All/decisions/2026-10-02-flight-cutscene.md`.
The `.4` patch makes the aircraft visibly coarser pixel art and lands every flight
inside its actual airport. Included ground transfers, airport/platform reloads,
street-first impressions and local story tracking complete the arrival flow without
changing approved scenery or collision borders. Arrival checks: 260; flight: 114;
uninterrupted recording: 7; journey: 944; mechanics: 1,075; city references: 9,810;
packaged data: 144; standalone release startup: exit 0. Existing headless shutdown
warnings remain documented. See `Foreign to All/decisions/2026-10-02-airport-arrivals.md`.
The `20261003.1` build adds the persistent day/night cycle: local 24-hour HUD clock,
40-minute active days, reading/focus pauses, shared world lighting, readable indoor
spaces, core hotel/airport window views, rest choices and time-aware travel.
Natural mornings satisfy Berlin's invitations without expiring appointments.
Existing saves migrate; malformed optional clock data never rejects a journey.
794 graphical cycle checks, 65 detail/greeting checks, 3 preview checks, 944 journey,
1,075 mechanics, 121 notebook, 93 headless flight and 148 packaged-data checks pass.
Standalone release startup exits 0. Four existing static flags remain in MapAtlas,
MapView and AudioManager; existing headless resource-at-shutdown warnings remain.
See `Foreign to All/decisions/2026-10-03-day-night-cycle.md` and
`.build/daynight-review/daynight-preview.mp4` (accelerated demonstration).
The finished 30-track
music pass is preserved. Full evidence and limitations:
`Foreign to All/decisions/2026-10-01-beta-release-preparation.md`.

## Direction

Keep the language and culture challenge. Money, repetitive labour and waiting
for a flight must not be the challenge. Preserve the Berlin street-story
work and extend its useful mechanics, rather than keeping the earlier chapter
panels as the final design. Approved scenery/depth work remains in place.

## Installed

- Berlin: four staged chapters plus the return-message scene; physical crates,
  an errand to Emil, his individual preference for forms of address, sleep
  transitions, an accessible route to the celebration, and the chair ending.
- Istanbul: four staged courtyard chapters. Different tea preferences, an
  invitation mistaken for a sale, askıda ekmek discovered at the bakery,
  permission to photograph an individual, Arda's need for a break, and a Bayram
  invitation that does not require labour. One tray delivery; optional parcel.
- London: four staged terrace chapters. An indirect request mistaken for a
  capability question; checking a person's tea order; Nadia's portfolio versus
  an assumed shift; a paid design job or a genuine refusal; asking what distance
  works for Mr Ahmed's niece; a placed direction sign and a drawing to keep.
  Later dialogue remembers the poster decision and viewing preference.
- Paris: four street chapters, Odile/Inès/Marcel's different expectations,
  uncertain invitations, actual chair/bread actions and preferences remembered.
- Moscow: two physical brooch trays, a repaired misunderstanding, Alina choosing
  the clasp, privacy, Viktor's football enthusiasm and a playable meal choice.
- Mumbai: phone versus stage drawing, multilingual notice choices, clear routes,
  optional chair delivery, participation without compulsory ritual or work.
- Tokyo: practical cup choice, contextual daijoubu, a private folded wish,
  reachable bamboo, and the player's own wish/display decision in the ending.
- Mexico: a particular familiar cup, laughter alongside grief, limited recording
  permission, optional flower delivery and the family's remembered preferences.
- Shared story mechanics: real character art/props, collision at feet, branching
  reactions, contextual unknown speech, exact speech replay, recoverable errors,
  saved stages, safe scene departure, movement/load cleanup. Companions and
  visible props remain after a conversation for the current street visit.
- Meanings are separate from recognition. Hearing a phrase does not mark it as
  used. A gesture does not award speaking credit. First wrong interpretations,
  confirmed meanings and discovery moments are retained in the journal.
  English is readable, but only confirmed interpretations get a discovery mark.
- All eight cities retain native room/ticket conversations. Essential fares and
  room prices exist; funds are supplied at payment if needed. No compulsory job,
  fluency or overnight requirement for flying. Core invitations can be declined
  without losing standing. Individual formality/correction feedback is enabled.
- Activities use choices and resumable progress. Outing requirements vary by city
  through `Journey.OUTING_PLAN`; the friend's district remains part of the story
  outside Berlin's bespoke arc. Extra activities are optional.
- Separate automatic checkpoint; manual slots remain separate. Tests redirect
  both saves and settings into unique disposable directories.
- Local feedback via Pause, with optional approximate active reading/exploring
  time per city. Nothing uploads automatically. Feedback UI, focus restoration
  and the discovery notebook have been visually reviewed in the real game UI.
- Every person who speaks is voiced: 577 lines from 100 speakers in all 20
  cities. That covers the stories, city rosters, key people, encounters,
  Berlin's hand-built NPCs and the counters, plus the crowd and the notebook's
  words. Each character has an ElevenLabs voice designed from their brief in
  `tools/voice_cast.json` and recorded with Eleven v4. Every clip is
  transcribed back and re-taken if it misspoke, and all are levelled to -18
  LUFS. Re-record with `tools/export_all_speech.gd`, then
  `python tools/eleven_voices.py record <speaker>`; `tools/voice_test.gd`
  checks coverage and wiring. See
  `Foreign to All/decisions/2026-09-30-character-voices.md`. Native review is
  still pending; the reviewer pack is in `docs/beta-language-review/`.
- Desktop export presets explicitly include required runtime layout, object,
  activity and speech JSON files. A local Windows candidate is now packaged;
  it has not been uploaded or publicly released.
- 44 activity-only settings are now freely explorable through 31 street
  entrances. They retain the existing activities as optional interactions,
  return routes, object depth, map/quest routing and saved standing positions.
  Full inventory: [Explorable activity locations](explorable-activity-locations.md).

## Active follow-up

All eight cities now have staged stories and explorable activity settings.
The activity inventory's 64 background identifiers are accounted for: 44 new
world locations, 17 already playable settings, and three alternate views that
share a location. The Späti, workshops, shops, squares and other settings can
be visited independently of their activities. See
`Foreign to All/decisions/2026-09-29-explorable-activity-places.md`.

The later character-voice pass supersedes the earlier five-language crowd
checkpoint: crowd speech is recorded in 16 languages. Native review remains open.

The journal's Words page is a notebook of what the player engaged with
(`scenes/ui/Notebook.gd`): words worked out, words noticed, and one line for
filler picked up by ear. Overheard words never toast. Key words are spelled
out in amber while the player decides, turn gold when confirmed, and are
recognised later in new sentences. First-time glyphs flicker without moving
the line. The 127 key words taught by stories and district
activities are voiced one at a time for the notebook's ▶. After changing a
story's confirm/misread keys, regenerate them with
`godot --headless --path . --script res://tools/export_key_words.gd`, then
`python tools/eleven_voices.py record <that language's notebook voice>`. See
`Foreign to All/decisions/2026-09-29-words-that-stick.md`.

Remaining release work includes native/local reviewers, continuous tester
playthroughs, measured pacing, intermittent shutdown diagnostics, and any issues
revealed by those sessions. The first Windows export/package checks are complete.
Twenty minutes per city is still an unmeasured design target. Exhaustive
scenery/corner QA remains deferred as requested.

## Evidence and limits

Godot 4.7.2. Scripted routes plus rendered screenshots, not a continuous manual
campaign playthrough:

- `tools/berlin_story_test.gd`: three routes, 209 checks, zero failures.
- `tools/istanbul_story_test.gd`: three routes, 124 checks, zero failures;
  small-step collision movement on the new tray/parcel routes.
- `tools/london_story_test.gd`: three routes, 148 checks, zero failures;
  collision movement, refusal, leaving mid-carry and real checkpoint reload.
- `tools/paris_story_test.gd`: 143 checks, zero failures.
- `tools/moscow_story_test.gd`: 143 checks, zero failures.
- `tools/street_story_test.gd -- CITY`: Mumbai 137, Tokyo 123, Mexico 146;
  three routes each, zero failures, rendered captures reviewed.
- `tools/beta_journey_test.gd`: updated for all eight staged stories; shared
  activities, essential travel, progression gates, interruption/save/reload and
  naming ending. Real street stories run in the city harnesses above.
- `tools/beta_mechanics_test.gd`: 1,075 checks, zero failures; eight-city counters,
  financial safety net, declined invitations, feedback and all 415 authored clips.
- `tools/activity_places_test.gd`: 1,035 checks, zero failures; all 44 new
  locations, collision-walked interaction/exit routes, 31 district activities,
  real entrance/return transitions, map/quest links, save and checkpoint reload.
  All entry captures reviewed; targeted final geometry/palette reruns pass.
- `tools/notebook_test.gd`: 25 checks, zero failures with the new places
  installed, including a steady line width while first-time glyphs flicker.
- `tools/rep_toast_test.gd`: 8 checks; the reputation card holds 4.5s.
- `tools/beta_support_ui_review.gd`: feedback and notebook captures plus focus,
  save/export and layout checks. The first screenshot exposed a collapsed
  feedback panel; the viewport-sized fix is included.

Logs and captures live in the local working folder under `work/beta/`.
Headless shutdown still reports small ObjectDB/resource diagnostics in some
harnesses. The suspended story callback found on scene departure was fixed;
these remaining diagnostics are not a claim of a clean release build.
