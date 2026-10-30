# Guided code tour

Start with [`project.godot`](../project.godot), which defines the title scene, autoload order, viewport, and compatibility renderer. The game is written in GDScript; Python and PowerShell support production and packaging, and TypeScript/React support the films.

## 1. Persistent state and a recoverable journey

[`GameState.gd`](../autoload/GameState.gd) holds shared player and world state. [`SaveManager.gd`](../autoload/SaveManager.gd) serializes the journey and handles manual slots and checkpoints. [`BuildInfo.gd`](../autoload/BuildInfo.gd) supplies the game version, build identifier, and save schema.

This is a useful starting point for reviewing how discoveries, relationships, travel, and returning to a city persist beyond a single scene.

## 2. Turning unfamiliar words into discoveries

[`Speech.gd`](../scenes/dialogue/Speech.gd) and [`DialogueBox.gd`](../scenes/dialogue/DialogueBox.gd) present speech and conversation. [`WordHints.gd`](../autoload/WordHints.gd) provides contextual small-word hints. [`WordDiscovery.gd`](../scenes/ui/WordDiscovery.gd) presents the persistent discovery panel; [`Notebook.gd`](../scenes/ui/Notebook.gd) keeps words and evidence available afterward.

Read [`word_context_test.gd`](../tools/word_context_test.gd), [`word_affordance_test.gd`](../tools/word_affordance_test.gd), and [`notebook_test.gd`](../tools/notebook_test.gd) alongside these files to see the behaviors the project verifies.

## 3. Eight city stories, flexible order

[`Story.gd`](../autoload/Story.gd), [`Journey.gd`](../autoload/Journey.gd), and [`CityChapters.gd`](../scenes/story/CityChapters.gd) connect discoveries, chapter progress, celebrations, onward travel, and the ending. [`Services.gd`](../autoload/Services.gd) implements interactions such as transport and local services.

[`beta_journey_test.gd`](../tools/beta_journey_test.gd) exercises the journey, while [`quest_guidance_edge_test.gd`](../tools/quest_guidance_edge_test.gd) covers cases such as leaving a city unfinished and returning later.

## 4. A readable world

[`Player.gd`](../scenes/player/Player.gd) handles the player in the world. [`WorldArt.gd`](../autoload/WorldArt.gd) and the files in [`scenes/world/`](../scenes/world/) assemble and present environments. [`JourneyClock.gd`](../autoload/JourneyClock.gd) and [`ClockIndicator.gd`](../scenes/ui/ClockIndicator.gd) connect local time to the player interface. [`Controls.gd`](../autoload/Controls.gd) and [`UIStyles.gd`](../autoload/UIStyles.gd) centralize input and presentation conventions.

## 5. Getting a playable artifact to someone else

[`package_beta.ps1`](../tools/package_beta.ps1) builds the Windows package. [`desktop_distribution.py`](../tools/desktop_distribution.py) packages Linux and macOS exports. [`native_desktop_verify.py`](../tools/native_desktop_verify.py) validates immutable packages on native systems. These include checksums, build identity, notices, extraction checks, and tests that require complete success summaries.

[`research_film_capture.gd`](../tools/research_film_capture.gd) records the gameplay demonstration through input paths. The [research film source](../trailer/src/research/) edits those recordings and adds captions.

See [setup and verification](BUILD_AND_TEST.md) for commands and [verification evidence](VERIFICATION.md) for the distinction between source checks, exported-game checks, and human evaluation.
