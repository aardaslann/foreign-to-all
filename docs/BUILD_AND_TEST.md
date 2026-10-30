# Run, build, and verify

## Play an existing build

Use the [beta release](https://github.com/aardaslann/foreign-to-all/releases/tag/v0.2.1-beta.1). Extract the complete archive and follow its start guide. Godot is not required for a packaged build. Windows targets 64-bit Windows 10/11; Linux targets x86_64. Both require suitable graphics support; these are target configurations rather than measured minimum-performance guarantees.

## Run the source

1. Install **Godot 4.7.2 Standard** (GDScript; the .NET edition is unnecessary). This is the version recorded in the existing tested build manifests.
2. Clone this repository, or use GitHub's **Code → Download ZIP** and extract it. The source includes substantial art and audio, so allow time for the download and first import.
3. In Godot's project manager, choose **Import** and select the root `project.godot`.
4. Allow the first asset import to finish, then press **F6** only for an individual scene, or **F5** to run the complete project from its title screen.

The game works offline with bundled assets. No API keys, paid generation services, Python packages, or Node modules are needed to play it in Godot.

Command-line equivalent, with `godot` pointing to the matching editor executable:

```sh
git clone https://github.com/aardaslann/foreign-to-all.git
cd foreign-to-all
godot --headless --editor --path . --import
godot --path .
```

## Build a desktop executable

Install the **matching 4.7.2 export templates** through Godot's **Editor → Manage Export Templates**. The root `export_presets.cfg` contains Windows, Linux, and macOS presets. Use **Project → Export** to choose a destination outside the source files.

For the existing packaging tools, use PowerShell on Windows and Python 3.12 or newer:

```powershell
./tools/package_beta.ps1 -Godot "C:/path/to/Godot_console.exe"
python tools/desktop_distribution.py --godot "C:/path/to/Godot_console.exe" --platform linux
python tools/desktop_distribution.py --godot "C:/path/to/Godot_console.exe" --platform macos
```

The tools expect export templates under the user profile and refuse to overwrite an existing build identifier. Choose a new `BUILD_ID` in `autoload/BuildInfo.gd` when creating a changed candidate. macOS packaging uses ad-hoc signing; a successful export is not public notarization or Gatekeeper approval. The beta release provides Windows and Linux packages, not the earlier private-test Mac binary.

## Run representative checks

Import the source before running scripts. Use a disposable operating-system user-data profile so checks cannot affect personal saves. In PowerShell:

```powershell
$savedAppData = $env:APPDATA
$savedLocalAppData = $env:LOCALAPPDATA
try {
    $testProfile = Join-Path $PWD '.build/source-tests'
    New-Item -ItemType Directory -Force $testProfile | Out-Null
    $env:APPDATA = $testProfile
    $env:LOCALAPPDATA = $testProfile
    $godotExe = 'C:/path/to/Godot_console.exe'
    & $godotExe --headless --editor --path . --import
    & $godotExe --headless --path . --script tools/beta_journey_test.gd
    & $godotExe --headless --path . --script tools/beta_mechanics_test.gd
    & $godotExe --headless --path . --script tools/quest_guidance_edge_test.gd
    & $godotExe --headless --path . --script tools/player_feedback_test.gd
    & $godotExe --headless --path . --script tools/word_context_test.gd
} finally {
    $env:APPDATA = $savedAppData
    $env:LOCALAPPDATA = $savedLocalAppData
}
```

Check each exit status and the final `checks / failures` summary; a process merely starting is not a passed suite. On Linux, use disposable `XDG_DATA_HOME` and `XDG_CONFIG_HOME` directories. Graphical review tools need a display; `packaged_smoke.gd` is intended for exported game data rather than a source checkout.

Packaging-unit checks use Python's standard library:

```sh
python -m unittest discover -s tools -p test_desktop_distribution.py
python -m unittest discover -s tools -p test_native_desktop_verify.py
```

## Trailer and asset-production source

The `trailer/` folder contains a pinned `package-lock.json`. Install Node.js/npm, then run `npm ci` in that folder. The [gameplay film](../trailer/src/research/README.md), [Understanding v7](../trailer/src/understanding-v7/README.md), and [Welcome](../trailer/src/welcome/README.md) each document their production steps. Generated footage and intermediate media are not in Git; reconstruct the inputs described by each composition before rendering it. Finished films are provided as release attachments.

Asset-generation utilities are included as production source. Some require optional packages, FFmpeg, or the author's chosen external services; they are not prerequisites for running the bundled game. Supply your own credentials only if deliberately regenerating material. Never commit them.
