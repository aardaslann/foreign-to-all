# Foreign to All: Player Journey

Design artifact, 3 October 2026. This documents the current beta; no gameplay changes.

## Rough sketch

New Journey -> customize alien -> opening / Berlin -> meet Lukas -> notice words and objects -> try communicating -> discover meaning -> return to a friend -> celebrate -> choose another city.

Repeat the discovery / connection loop across the eight core cities. Berlin comes first; Istanbul, London, Paris, Moscow, Mumbai, Tokyo and Mexico City have no fixed order after that. Once all eight city celebrations are complete, return to the Berlin pod, choose a friend and receive a name. Exploration can continue afterward.

## Design intent

The intended emotional arc is curiosity -> uncertainty -> understanding -> confidence -> belonging. These are hypotheses for player research, not measured reactions.

The central learning loop is notice -> attempt -> observe the result -> revise meaning -> optionally use the word with another person. Hearing a word is not the same as understanding it. Pronunciation playback and notebook evidence support the player without turning the experience into an exam.

Personal discoveries and return visits advance each city's story. The player need not complete every optional activity, clear every location, earn money through work or perform each word-use encounter to reach the ending.

## Three editable pages

1. **Rough sketch:** a deliberately loose hand-drawn-style concept, not a photographed pen-and-paper drawing.
2. **Player journey:** actions, imagined player questions, intended feelings, touchpoints and design watchpoints across seven phases.
3. **Gameplay flow:** the learning loop, optional branches, city travel, ending condition and support systems.

Open `foreign-to-all-player-journey.drawio` in diagrams.net. Text, nodes and arrows are editable. The website editor is left open with the diagram; the file is the durable local copy. No Miro account was created and no public board was published.

The website copy is saved in this Chrome profile's browser storage, not a shared cloud board. `foreign-to-all-player-journey.pdf` is the three-page export from diagrams.net, checked visually after export. `journey-page-1.png` through `journey-page-3.png` are page previews; `journey-editor.jpg` shows the saved board in the website editor.

## Existing support systems

- Local 24-hour clock; 40 active exploration minutes per day; reading, menus, films and lost focus pause time.
- Beds offer 08:00 or 18:00 rest. Natural mornings can satisfy Berlin invitations; available story opportunities do not expire.
- Flights end at the destination airport, create a checkpoint and include one onward transfer. Clock times change with travel and local offsets.
- Essential fares/purchases have safety nets. Essential services remain available.
- Continue restores a manual save or checkpoint. Saved cosmetic choices persist through scenes.
- After naming: continued exploration, credits and optional locally saved feedback. The pod can replay the naming.

## Sources

- `docs/beta-player-guide.md`
- `Foreign to All/activecontext.md`
- `Foreign to All/decisions/2026-09-29-discovery-first-beta.md`
- `Foreign to All/decisions/2026-10-02-beta-review-fixes.md`
- `autoload/Journey.gd` (city rhythm and next intentions)
- `autoload/Story.gd` (`can_end`: eight completed celebrations)
- `scenes/world/WreckSite.gd` (friend selection and naming)

## Validation questions for a later player study

- Can a new player identify one next action after reaching Lukas?
- Can they explain a word from its context rather than guessing from a translation?
- Do optional word-use encounters make recall feel useful?
- Is each return to a friend motivated by curiosity rather than completion pressure?
- Can they navigate airport -> town without guidance from the developer?
- Does the chosen name feel connected to a specific shared memory?

These questions are research suggestions, not new features or completed test results.
