# Development and materials

## Project responsibility

Foreign to All is Arda Aslan's game project. Arda leads its concept, creative and design direction, production, and iteration. The project connects language, culture, and belonging through a playable narrative rather than presenting them only as an essay or a vocabulary exercise.

Character speech is synthetic; the production tooling includes an ElevenLabs recording pipeline. The city music was made with Suno.

## What is included

- Game scripts, scenes, configuration, and bundled runtime assets.
- Automated checks and distribution tooling.
- Source for promotional films and the gameplay demonstration.
- Current player-journey materials and selected historical design documents.
- Build identities, checksums, and verification records for the released artifacts.

This publication is a new, single-snapshot repository. The original local development history remains in the working project. It is not backdated or presented as a public history of daily work. Private study material, participant responses, service-account details, editor state, and redundant generated review captures are excluded.

## Technology and credits

- **Godot Engine:** game runtime and editor. Engine/component notices are in [THIRD-PARTY-NOTICES.txt](../THIRD-PARTY-NOTICES.txt).
- **Noto fonts:** Japanese, Korean, Devanagari, and Georgian font files carry their SIL Open Font License notices in [`art/fonts/`](../art/fonts/).
- **Remotion, React, and TypeScript:** film and promotional-material source; dependency versions are recorded in [`trailer/package.json`](../trailer/package.json) and its lockfile.
- **ElevenLabs:** character voices, recorded through [`tools/eleven_voices.py`](../tools/eleven_voices.py).
- **Suno:** city music, cut into seamless loops by [`tools/music_loop.py`](../tools/music_loop.py).

The source publication does not grant a blanket license to third-party services, voices, fonts, or other components. See [rights](../RIGHTS.md).
