# Verification and artifact identity

## Source checks — 30 October 2026

The curated repository was tested as a separate source copy with a fresh Godot import cache and isolated user-data profile, using **Godot 4.7.2** on Windows.

| Check | Result |
| --- | --- |
| Fresh headless editor import | Exit 0 |
| Main-scene headless startup | Exit 0; known shutdown resource warnings |
| Full beta journey | 944 checks, 0 failures; 245 staged shots traversed |
| Beta mechanics | 1,075 checks, 0 failures |
| Quest-guidance edge cases | 51 checks, 0 failures |
| Player-feedback mechanics | 71 checks, 0 failures |
| Word context | 87 checks, 0 failures |
| Python distribution tests | 16 tests: 15 passed, 1 platform-specific test skipped |
| Python native-runner tests | 4 passed |

These are **2,228 GDScript checks** plus the Python tests, re-confirmed with identical results on the final source before publication. The source checks do not constitute a new full human playthrough. Some headless suites emit known shutdown resource/ObjectDB diagnostics; test completion and zero failure summaries are recorded separately. Commands are in [BUILD_AND_TEST.md](BUILD_AND_TEST.md).

## Playable packages — build `20261030.1`

The release's Windows and Linux packages were built on 30 October 2026 from this repository's source with Godot 4.7.2 and the packaging tools in `tools/`, as `0.2.1-beta.1 / 20261030.1`. Each package's `build-manifest.json` records its source commit, engine version, and executable hash. The release's `SHA256SUMS.txt` and [`release-files.json`](release-files.json) identify the exact uploaded files.

| Check | Windows | Linux |
| --- | --- | --- |
| Packaged-data smoke (`packaged_smoke.gd`, graphical, matching Windows editor hosting the exported data) | 139 checks, 0 failures | 139 checks, 0 failures |
| Release executable, headless start | Exit 0 | Not yet run natively |

The Linux package's game data was tested through the Windows editor; its native executable has not yet been run on Linux. [`tools/native_desktop_verify.py`](../tools/native_desktop_verify.py) performs that native check.

- **Source provenance:** prepared from local development snapshot `e3a007c`, whose later commits also include film and presentation work. This original history identifier is a provenance reference, not a commit link in this repository.

### Earlier candidates (historical)

On 4 October 2026, the earlier Linux candidate `20261004.6` passed native headless/graphical startup and seven exported-data suites totaling **2,457 checks** on Ubuntu 24.04 x86_64 ([native report](evidence/native-report-linux-20261004.6.json)). The same native verification ran on Intel and Apple Silicon Macs ([Intel report](evidence/native-report-intel-mac-20261004.6.json), [Apple Silicon report](evidence/native-report-apple-silicon-20261004.6.json)). The earlier Windows candidate `20261004.4` is described by its [build manifest](evidence/windows-build-manifest.json). These records describe those earlier candidates, not the current packages. The Mac candidate was ad-hoc signed for private testing, not notarized for public distribution, and its binary is not part of this public release. The source includes the Mac export configuration.

## Limits

- Automated checks establish specific mechanics and startup behavior, not every possible player path or all hardware configurations.
- Native cloud rendering checks do not establish consumer GPU frame rates or minimum hardware requirements. Physical audio/controller evaluation remains separate.
- Native-language review, cultural nuance, synthetic pronunciation quality, and wider human playtesting remain unfinished.
- The English interface is complete for the beta; other interface languages are previews with English fallback.
- No measured learning benefit, retention effect, or study outcome is claimed.

This source snapshot excludes private account notes, study records, and credentials. A preparation scan checked common credential formats, private Google document links, and personal-email patterns in the selected text files; no matches were found. Each file is below GitHub's 100 MiB regular-file limit. This is a focused publication check, not a claim of a comprehensive security audit.
