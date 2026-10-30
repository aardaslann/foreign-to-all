# Foreign to All - Linux Beta

Target: a current x86_64 Linux desktop with OpenGL 3.3 support. ARM Linux is not
included in this package. See the accompanying native-test report for the exact
tested distribution; exporting alone is not a compatibility certification.

Extract the entire `.tar.gz` archive. Keep `ForeignToAll.x86_64` and
`ForeignToAll.pck` in the same folder. Open `ForeignToAll.x86_64` to play, or run
`./ForeignToAll.x86_64` from that folder. The archive preserves its executable bit.
Do not run the game as root or install it in a system directory.

For Steam, add the executable as a non-Steam game if desired. This is a native
Linux build; it does not require Proton or a Windows compatibility layer.

Saves normally live in `~/.local/share/godot/app_userdata/Foreign to All/saves`.
If `XDG_DATA_HOME` is configured, the location follows that directory instead.
Back up the complete `Foreign to All` user-data folder before replacing a build.
Manual save files use the same schema as Windows and macOS; Steam Cloud is not
configured and transferring a save is not automatic.

Read `PLAYER-GUIDE.md` for gameplay and controls. If a bug occurs, include the
build ID from `build-manifest.json`, your distribution/desktop, and the local
feedback file. Nothing is uploaded by the game.

The archive's checksum verifies the exact candidate. `native_testing: pending`
in its export manifest means it was built before native checks; the separate
test report identifies that checksum and records their actual outcome.
