# Environment and activity redesign

Authorised by Arda on 10 September 2026: implement the approved environment concepts across all 20 cities and improve the activity scenes to match. Keep every existing building function, activity consequence, character design and environmental animation. New concept boards do not need people baked into them.

Scope: 193 environment scenes, 99 district activities (450 beats, 259 authored shots). The sparse Room01 prototype is part of the environment inventory. Existing narration, cultural content, costs, rewards, branching, language exposure and save identifiers remain authoritative.

Baseline: commit 25ffe60. Static, call arity, door, streetside, film and name checks all pass. Source art and architecture notes have been read; several older vault summaries are stale, so executable code is the authority for current behaviour.

The first playable revision was integrated from the environment-redesign branch into the main game project on 11 September 2026, commit 54e47ff. Native renders from that main project confirm the new artwork and live characters in Mitte, Hanoi Hotel and Honolulu Hotel. This is an implementation checkpoint; visual refinement continues. The approved visual boards and current-scene comparisons are in the task's outputs/foreign-to-all-revised-city-design-review directory.

## Delivery sequence

1. Prove a complete city using its approved art, real player and functional doors, service points, collision, lighting and animation.
2. Give activities the same environment renderer and improve their action timing, camera staging, prop interaction and readable character animation.
3. Extend the scene-specific layouts and ambient animation definitions to every environment and review all 99 activities, including alternate/repeat paths.
4. Run the repository checks, engine scene/barrier checks, functional interaction checks and visual renders. Merge the verified work into the game project and update the vault.

## Preservation requirements

- Visible doors and signs must correspond to their actual SceneExit targets. Preserve return-door and arrival logic.
- ServicePoint identifiers and Streetside beat graphs retain their consequences. Move their visible interaction positions with any new counter or activity location.
- Collision footprints must match new furniture, and crowd paths must use those same footprints.
- Keep day/night behaviour, animated transport, water, foliage, signs and other existing motion. A concept image alone is not a finished environment.
- Activity backgrounds must be the district's actual art. Indoor activity sets must share the city's material palette and visual scale.
- Existing player, named cast, wardrobe and crowd character designs remain the source of truth. Concept-image characters are not game assets.

## Progress

- [x] Baseline and gameplay architecture inventory
- [x] Complete all 23 approved-direction boards (193 scenes)
- [x] Playable city proof
- [x] 193 environments wired to live scenes; individual full-size backgrounds visually inspected
- [x] Shared activity staging, movement, props and seven additional location plates implemented
- [x] 99 activity sequences rendered through the actual cutscene renderer
- [x] Engine checks: 183 scripts compile, 201 scenes instantiate, 193 environments / 624 interaction areas reachable
- [x] Content checks: 99 activities / 450 beats and 259 authored shots clean
- [ ] Complete visual review of alternate activity branches and final motion polish

## Production assets and remaining review

The 193 production scene images are individual approximately 1672 by 941 assets. They replace the original contact-board crops; backgrounds use linear filtering while characters retain their pixel grid. layouts.json holds gameplay geometry and fullsize.json holds the production asset references and measured corrections. Buildings retain their original SceneExit and ServicePoint behaviours.

Activity staging includes action timing, stable cast appearance, carried objects, continuous swim surfaces and a matching bathhouse interior. Seven independent landmark/interior plates use activity-sets.json. All art is separate from live characters and interaction logic.

Known work remaining: refine transport layer masks and looping joins, localized night lighting, entrance plaques and counter placement, remaining shot-specific action/prop alignment, and correct a few baked sign words in New York. These are visual refinement items; this checkpoint is not a claim that the entire redesign is finished.

Test harnesses use a task-local APPDATA directory; project.godot retains the original save configuration. No player save data is migrated or reset.

The separate Remotion trailer directory is excluded from Godot's import scan by trailer/.gdignore. Its editing sources and rendered films remain available; the game does not reference those assets.
