# Berlin and Istanbul — implementation checkpoint

Updated 2026-09-14. Installed directly in `C:\Users\Arda\Projects\foreigntoall`.

## Current: whole-object depth and final contact review

All 28 scenes now have complete source/foreground comparisons and 218 eight-view
contact cards. The Han plant/display and full tree branches/crowns sort together;
countertop items, chair backs, trolley handles, produce and railings were completed.
Four missing objects were added and 79 existing objects revised across 25 scenes.
MitteOst's opaque shelter panel and both shelters' ground planes stop crossing
through them. The U-Bahn back pavement remains open; its full ironwork now sorts
correctly. Prenzlberg's tall post and short bollards have individually measured
outlines. The approved background illustrations are unchanged by this pass.

The final combined floor results contain 158,850 connected six-pixel samples.
The full sweep made 317,646 movement steps; affected scenes were repeated after
refinements, with no failures. All 114 interactions and 38 arrival routes pass,
along with campaign, services, whole-object pixel probes, near fountain corners,
water animation, Room 304 departure, activity continuity and pedestrian simulation.
Six Python checkers pass; Godot compiles 205 scripts and steps 202 scenes cleanly.

See [screenshots, provenance, logs and coverage limits](review/depth-completion-2026-09-14/README.md).
This is scripted engine testing and visual inspection. Distant contact views,
isolated hotel furniture pockets, the Hospital bench-width heuristic, dedicated
corridor flow and harness shutdown diagnostics are documented in that review.

## Previous: continuous contact and saved-position recovery

The intensive follow-up traversed 158,889 connected six-pixel floor cells in
all 28 scenes with the real Player body: 317,722 movements, zero failed routes.
214 eight-view contact cards were rendered and visually reviewed. Sole clearance,
the pavement behind the U-Bahn railing, the poster base, both near fountain
corners, crowd navigation and saved-position recovery are corrected. The stair
hole is solid: the earlier front-entry interpretation below is superseded.
Room 304's visitor now crosses the opening threshold and the foreground door
animates. Kiez/Karaköy activity placements clear the rock/bollard.

The seven shared-crowd scenes passed 2,016,000 samples for 56 people over ten
simulated minutes each. All 114 interactions and 38 arrivals pass; campaign,
services, object/pixel checks, Room 304 departure and activity continuity pass.
Six Python checks are clean; 203 scripts compile and 202 scenes step cleanly.
All nine activity settings and the two revised reels were visually reviewed.

See [contact evidence, coverage limits and logs](review/contact-audit-2026-09-13/README.md).
This is finite scripted engine testing and visual inspection, not an uninterrupted
manual campaign playthrough. The two isolated hotel furniture pockets now have
tested save recovery; their collision geometry has not been patched with walls.

## Previous: complete scene object inventory

All 28 installed scenes were inspected in the Godot renderer against their
collision footprints and foreground outlines. The registry contains 214 objects:
24 new entries and 67 revised entries. The U-Bahn landing is accessible behind
its rails, the bicycle handle is repaired, Prenzlberg's front park fence is solid
with a usable gate, and the Han fountain blocks all four approaches. Han's tree
and other reachable plants now retain their leaf gaps and correct front/back depth.
The pass also corrects street boards, booth backs, chairs, trolleys, tabletop
objects, a wardrobe and the Room 304 desk. The approved artwork and the full
Kiez stone path are preserved.

Final validation: six required Python checkers clean; 200 scripts compile and
202 scenes instantiate/step; 28 scenes, 114 collision-walked interactions and
38 arrival routes pass. Campaign, services, focused object checks and the prior
Kiez exit/post-pixel regressions pass. This is scripted verification plus visual
inspection, not a full manual campaign playthrough. The reviewed Hospital bench
width warning and dedicated HotelRoom corridor warning are documented with
[the complete inventory, 51 captures and logs](review/object-audit-2026-09-13/README.md).
The dated sections below describe earlier checkpoints and their former counts.

## Follow-up: original stone path and narrow post outlines

The 23:58 screenshots corrected our interpretation of the Kiez stone strip:
it is walkable ground. The full original artwork is restored, the added grass
patch/stepping stones/post are removed, and only the fence behind the path
blocks movement. Separate stall, crate and mailbox footprints remain.
The exit marker is on the path and the real-time walking/E regression reaches
Mitte. No production background PNG was edited for this correction.

Sixteen bollards, four poles, Karakoy's lamp and Kadikoy's signpost now follow
their narrower silhouettes. Exact pixel checks at the reported Mitte bollard
confirm that the shaft hides the player while adjacent coat pixels survive.
There are now 190 authored objects. The walking audit passes 28 scenes, 114
interactions and 38 arrival routes; campaign/services and required checks pass.
Godot compiles 198 scripts and steps 202 scenes. Reviewed captures and retained
warnings are in [current evidence](review/stone-path-2026-09-13/README.md).

The older gate-opening/garden-wall description below is superseded by this
correction. Other historical results remain useful only within their coverage.

## Follow-up: reported stall, mailbox and blocked exit

The 17:10/17:11 screenshots exposed a further gap. Kiez now has separate
stall/wall/crate depth, a visible opening to the exit, and mailbox/apple-crate
footprints. Native fixtures use independent foreground layers. Four Istanbul
exit glows were moved onto clear floor. Geometry contains 191 objects.

The audit now walks all 114 interactions from spawn using player collision
sweeps and requires the exact exit-marker position to be clear and connected.
All 28 scenes and 38 arrival routes pass. A real-time Kiez walk reaches Mitte
through E input; campaign, service and object checks pass. Godot compiles 197
scripts and steps 202 scenes. See [current evidence](review/boundary-routes-2026-09-12/README.md)
for screenshots, methods and retained warnings. Older results below are historical;
trigger overlap and direct test placement alone do not prove a walking route.

## Correction after the user's screenshot review

The original layout pass missed opaque image crops and shallow collision bands.
Its foreground-mask acceptance was too broad. The follow-up installs 187 authored
objects across the 28 scenes, with separate ground footprints, silhouettes and
transparent glass. It also removes double cropping of desk NPCs, fixes and animates
the Room 304 exit, animates the Han fountain without moving its masonry, replaces
78 signs/boards with native text, and fixes caption-driven camera drift and repeated
activity arrivals. Kreuzberg's cast stays off the fence and the Han courier stays
beside the fountain.

Current evidence: [object-fixes-2026-09-12](review/object-fixes-2026-09-12/README.md).
The latest run compiled 196 scripts and stepped 202 scenes with zero failures.
Layout, campaign, service, object-collision and activity-continuity checks pass.
The barrier audit reports one reviewed warning for the visible hospital bench;
its accessible route around the seats passes the layout check. The table below
also retains earlier friendship/flight coverage, which was not rerun for this
presentation correction. This is scripted verification, not a complete manual
campaign playthrough.

## Installed

All **28 world backgrounds** (15 Berlin, 13 Istanbul) use the detailed `scenes/*-retro.png` assets. The richer approved architecture is preserved with fine pixel clusters, stepped edges, discrete material shading and nearest texture filtering. The original smooth images remain alongside them. The rejected simplified procedural redesign is not used.

`berlin-gameplay.json` and `istanbul-gameplay.json` bind the artwork to the actual world: door thresholds, service counters, collision, foreground occlusion, player arrival positions, working signs and activity locations. `EnvironmentDesign.gd` loads these overrides in the running game.

- **Lukas:** pouch, free apple crate and paid bread counter have separate interaction space. E at the customer side opens Lukas's dialogue and the paid trade completes its quest. The crate gives an apple and does not spend the player's money.
- **Buildings:** entrances align with visible buildings. Door labels require an explicit wall plaque or use the sign painted into the asset. The old automatic plaques above invisible street triggers are removed. Hotel room numbers are drawn from the actual floor and room doors.
- **Hotels:** Berlin's elevator, room 304, sleep quest and return to the correct door work together. Istanbul has a room-key requirement, local reception and an upstairs sleep interaction. Istanbul sleep uses a fade and returns to the lobby; there is no separate upstairs room scene.
- **Transport:** Istanbul's tram is a separate moving, depth-sorted object. Metro foreground columns and ticket machine mask correctly; the obsolete floating light rectangle is removed. Water patches avoid the pier posts; kitchen steam remains animated.
- **Story:** Arda's errand now describes the actual askıda ekmek activity in the Çarşı. The Han activity, Yusuf's hospitality sequence and Arda's conversations have independent interaction space.

## Activities

All **nine district activities** have per-shot staging in `activity-staging.json`: Kiez, Mitte, Prenzlberg, Kreuzberg, Han, Çarşı, Beyoğlu, Kadıköy and Karaköy. These records change presentation while keeping the authored choices, rewards, prices and story effects.

They reuse the world art and current character renderer. Two additional activity backgrounds are installed: the Späti interior and the ferry deck. `activity-plates.json` supplies these to the same environment renderer without adding world doors. Ferry water animates only between the railings. The Han courier has a chained tea tray, the workshop includes its craftsman, seated drinking remains seated, four people share the Späti doorstep, and Kadıköy's cats reuse the game's animated CatArt. Props are sized relative to characters and repeated background props are suppressed in directed close-ups.

## Verification

Test runs use disposable APPDATA folders, never the player's normal saves. Logs and actual Godot renders are in [review/berlin-istanbul-2026-09-12](review/berlin-istanbul-2026-09-12/).

| Check | Result |
|---|---|
| `design_playability.gd` | 28 scenes, 114 targets, 38 arrival routes; 0 failures |
| `design_campaign.gd` | 0 failures: actual opening paid trade, apple pickup, map, hotel/elevator/sleep, Yusuf's five stages, Istanbul activities and airport access |
| `design_friendships.gd` | 0 failures: Berlin/Istanbul conversations, errands, invitations and return of control after holidays |
| `design_services.gd` | 0 failures: hospital/police fragments, lost-property fee, crate/dish jobs, exchange, ticket purchases and station return routes |
| `design_flights.gd` | 0 failures: actual airport map clicks and transitions in both directions; sleep/word/fare guards, currency deductions and arrival input |
| `verify_scenes.gd` | 192 scripts compiled; 202 scenes instantiated and stepped; 0 failures |
| `barriers.gd` | 202 scenes, 260 solids; 0 suspects |
| Static/call/door/film/name/streetside checkers | Clean |
| Visual review | All 28 world scenes and 9 activity sheets rendered in Godot and inspected; tram, metro, water and night samples reviewed |

Coverage limits: service, flight and friendship tests seed the relevant funds, vocabulary, visits or job contracts. This is not a fresh-save playthrough of the entire twenty-city campaign. The route auditor warns about HotelRoom → HotelFloor because room doors are a dedicated system rather than reciprocal SceneExit nodes; the campaign test exercises that exact flow successfully. Several engine test processes report one ObjectDB instance at shutdown; no parse errors or runtime script errors were found in the final checks.

## Source and next scope

There are 30 installed assets: 28 world backgrounds and 2 activity backgrounds.

This checkpoint completes the Berlin/Istanbul implementation pass. The other 18 cities have not received this same pixel-finish and functional-layout pass. Continue those only after preserving the bindings and checks established here; do not swap pictures while leaving doors, collision or activities at old coordinates.
