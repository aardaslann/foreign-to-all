# Explorable activity locations

Installed in `C:/Users/Arda/Projects/foreigntoall`, 2026-09-29.

The eight beta cities now have 44 additional walkable locations, connected by
31 entrances on their existing streets. Approach the entrance and press E.
Inside, movement stays free; a separate interaction starts the original
neighbourhood activity. Each location has a return route. Entering or revisiting
a room does not complete an activity or grant its reward again.

## Where to go

Each arrow is a playable connection with a route back. Follow-up locations are
reached from the preceding location, not from an unrelated street.

| City | New locations | Routes from existing streets |
|---|---:|---|
| Berlin | 1 | Mitte → Späti; talk with Rika at the counter when ready |
| Istanbul | 1 | Kadıköy quay → ferry deck |
| London | 5 | Soho → pub; High Street → charity shop; Docklands → DLR platform → front carriage; Brixton → Tunstall Road mural |
| Paris | 7 | Marais → Rue des Rosiers → Place des Vosges; Montmartre → Place du Tertre → vineyard lane; Belleville → viewpoint; La Défense → Esplanade; Champ-de-Mars → lawn |
| Moscow | 7 | Kitay-Gorod → stolovaya; Basmanny → repair booth; Izmaylovo → Vernisazh → courtyard; Arbat → Tsoy wall; Zamoskvorechye → churchyard → gallery |
| Mumbai | 7 | Bhuleshwar → Kabutarkhana; Chor Bazaar → antiques shop; Colaba → Gateway promenade; Bandra → Mount Mary → sea promenade; Byculla → museum garden → museum hall |
| Tokyo | 9 | Yanaka → menchi shop → cemetery path; Jinbōchō → secondhand bookshop; Asakusa → Kaminarimon → incense forecourt → omikuji; Ueno → Ameyoko; Shinbashi → station square → standing bar |
| Mexico City | 7 | Merced → market aisle → loading courtyard; Roma → Plaza Río de Janeiro; Coyoacán → market → coyote fountain; Condesa → Parque México; Juárez → café corner |

The activity inventory contains 64 background identifiers: these 44 locations,
17 settings already playable, and three alternate views. LondonBinLid shares
LondonTerrace; ParisPortrait shares Place du Tertre; MumbaiKabutarFlight shares
Kabutarkhana. They deliberately do not create duplicate rooms. Istanbul's
existing workshop and the existing outdoor street settings remain accessible.

## Behaviour

- Movement uses ground footprints and separate full object silhouettes, with
  openings between legs, foliage cutouts and translucent display glass where
  applicable. Approved art, pixel filtering, lettering and animation are reused.
- Manual saves and the automatic checkpoint retain the location and standing
  position. Older saves continue to work.
- The map identifies the location using its actual scene artwork, with accurately
  positioned exits and interactions. A searchable city index and route diagram
  include the new rooms. The quest route graph includes both directions.
- Neighbourhood activities still use their original choices, language discovery,
  completion ledger and story gates. Multi-room locations share that ledger.
- The Kadıköy entry is on the quay approach; Basmanny's repair entrance is clear
  of Viktor's dialogue interaction. Arrivals step away from their matching door.

## Authoring

`tools/build_activity_places.py` owns the geometry, residents, entrances and
connections. Run it after changing those definitions, then run
`python tools/gen_scenegraph.py`. Generated files are
`art/environments/activity-world.json`, `scenes/world/activities/*.tscn` and
`scenes/world/SceneGraph.gd`.

`ActivityBackground.gd` merges world geometry into a copy of the activity art
record. It does not overwrite film staging. Geometry coordinates normally use
the original 1672 × 941 plate; the museum hall explicitly uses 1603 × 981.
Collision footprints describe occupied ground; silhouettes include the whole
visible object, not just its base or a rectangular crop of surrounding floor.

Runtime JSON is included in the desktop export presets. This pass did not
produce or validate a new exported executable.

## Verification and limits

`tools/activity_places_test.gd`: 1,035 checks, zero failures in the full graphical
run. It instantiates all 44 locations, walks collision paths to interactions and
exits, exercises all 31 distinct district activities, checks map/quest routes,
saves and reloads, and uses real E/fade transitions for all 31 street entrances
and returns. Test saves and settings go to disposable storage.

Runtime entry captures were reviewed for all locations. Targeted refinements
were then rerun: Rika's palette (19 checks), Place du Tertre (22), museum hall
(19), Coyoacán fountain (22, including two reachable views behind the complete
sculpture) and Condesa park (19); all zero failures. The park arrival and curved
foreground planting were corrected, as was the fountain's complete silhouette.
The fountain and park's final captures were visually reviewed.

Notebook regression: 18 checks, zero failures. Beta mechanics: 1,075 checks,
zero failures; that harness still emits small shutdown resource diagnostics.
The new activity-location suite's final full-run stderr is empty.

Evidence: local review captures under `work/beta/places/` (not included in this repository).
This is scripted traversal and visual review, not an exhaustive corner sweep or
a continuous manual campaign. Those wider audits remain deferred as requested.
Native review, measured pacing and final package validation remain separate
beta release work.
