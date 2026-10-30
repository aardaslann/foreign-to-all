# Foreign to All - macOS Private-Test Build

This application contains both Intel and Apple Silicon executables in one
universal bundle. See the native-test report for the exact macOS versions tested.

Extract the ZIP with Archive Utility and move `Foreign to All.app` to Applications
or another folder you own. The complete `.app` bundle is required. Do not extract
or send only its executable. Read `PLAYER-GUIDE.md` for gameplay and controls.

## Signing Status

This candidate is ad-hoc signed for native testing. It is NOT Apple Developer ID
signed or notarized, and must not be presented as a finished public Mac release.
macOS may block a downloaded copy. Do not disable Gatekeeper, remove quarantine
attributes, or change system security settings to run it. If blocked, wait for
the signed/notarized candidate or report the warning to the developer.

Ad-hoc signature verification and automated tests do not replace notarization.
A normal public download requires a Developer ID certificate and Apple's
notarization service, configured separately using secure credentials.

## Saves And Reports

Saves normally live in
`~/Library/Application Support/Godot/app_userdata/Foreign to All/saves`.
Back up the complete `Foreign to All` user-data folder before changing builds.
The save schema is shared with Windows and Linux; Steam Cloud is not configured.

The build ID and export details are in `build-manifest.json`. A separate native
test report records the tested archive checksum and results. An export manifest
with `native_testing: pending` never claims that a native test has already passed.
Audio, controller hardware and the downloaded application's security prompts
still require device-level review beyond automated cloud tests.
