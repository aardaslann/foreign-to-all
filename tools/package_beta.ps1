param(
    [Parameter(Mandatory=$true)][string]$Godot
)
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
# Godot and git print harmless warnings on stderr (an engine object alive at
# shutdown, a line-ending notice). Under 'Stop', Windows PowerShell turns any
# stderr line from a native program into a terminating error - that once
# aborted a finished build at the credits step. Native runs are judged by
# their exit code instead.
function Invoke-Native([scriptblock]$Run) {
    $previous = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try { & $Run } finally { $ErrorActionPreference = $previous }
}
$info = Get-Content -LiteralPath (Join-Path $root 'autoload/BuildInfo.gd') -Raw
$version = [regex]::Match($info, 'const VERSION := "([^"]+)"').Groups[1].Value
$build = [regex]::Match($info, 'const BUILD_ID := "([^"]+)"').Groups[1].Value
$schema = [regex]::Match($info, 'const SAVE_SCHEMA := (\d+)').Groups[1].Value
if (-not $version -or -not $build -or -not $schema) { throw 'Missing build identity.' }
# Measured, not asserted: uncommitted changes to anything the export ships.
# Development-only folders (excluded from the export) do not count.
$devOnly = '^(trailer|tools|docs|Foreign to All|\.build|build|art/environments/review|art/environments/city-art-batches)/'
$status = @(Invoke-Native { & git -C $root status --porcelain=v1 --untracked-files=all 2>$null })
if ($LASTEXITCODE -ne 0) { throw 'Could not read the source tree state.' }
$dirty = @($status | ForEach-Object { "$_".Substring(3).Trim('"') } |
    Where-Object { $_ -notmatch $devOnly -and $_ -notmatch '__pycache__' })
$name = "ForeignToAll-$version-$build-windows"
$package = Join-Path $root "build/$name"
$zip = "$package.zip"
if ((Test-Path -LiteralPath $package) -or (Test-Path -LiteralPath $zip)) {
    throw 'This build ID already has output. Use a new build ID instead of replacing a distributed candidate.'
}
$godotPath = (Resolve-Path -LiteralPath $Godot).Path
$sourceProfile = $env:APPDATA
$profile = Join-Path $root '.build/export-profile'
$templates = 'Godot/export_templates/4.7.2.stable'
$templateDir = Join-Path $profile $templates
New-Item -ItemType Directory -Force -Path $templateDir | Out-Null
foreach ($file in @('windows_release_x86_64.exe','windows_release_x86_64_console.exe','version.txt','icudt_godot.dat')) {
    Copy-Item -LiteralPath (Join-Path (Join-Path $sourceProfile $templates) $file) -Destination $templateDir -Force
}
New-Item -ItemType Directory -Path $package | Out-Null
try {
    $env:APPDATA = $profile
    $exe = Join-Path $package 'ForeignToAll.exe'
    $log = Join-Path $root '.build/export-windows.log'
    Invoke-Native { & $godotPath --headless --path $root --export-release 'Windows Desktop' $exe *> $log }
    if ($LASTEXITCODE -ne 0 -or -not (Test-Path -LiteralPath $exe)) {
        throw "Export failed. See $log."
    }
    $errors = Select-String -LiteralPath $log -Pattern 'SCRIPT ERROR:|Parse Error:|Failed to export'
    if ($errors) { throw "Export reported script errors. See $log." }
    $privateFiles = Select-String -LiteralPath $log -Pattern 'Storing File: res://(tools|trailer|docs|Foreign to All|art/environments/review|art/environments/city-art-batches)/'
    if ($privateFiles) { throw "Export contains development-only resources. See $log." }
    $notesLog = Join-Path $root '.build/export-notes.log'
    Invoke-Native { & $godotPath --headless --path $root --script tools/export_release_notes.gd -- $package *> $notesLog }
    if ($LASTEXITCODE -ne 0 -or -not (Test-Path -LiteralPath (Join-Path $package 'THIRD-PARTY-NOTICES.txt'))) {
        throw "Could not export credits/notices. See $notesLog."
    }
    Copy-Item -LiteralPath (Join-Path $root 'docs/beta-player-guide.md') -Destination (Join-Path $package 'START-HERE.md')
    $manifest = [ordered]@{
        game = 'Foreign to All'
        version = $version
        build_id = $build
        save_schema = [int]$schema
        platform = 'Windows x86_64'
        engine = (& $godotPath --version | Out-String).Trim()
        created_utc = (Get-Date).ToUniversalTime().ToString('o')
        source_base_commit = (& git -C $root rev-parse HEAD | Out-String).Trim()
        source_includes_uncommitted_work = ($dirty.Count -gt 0)
        source_uncommitted_files = $dirty.Count
        music_tracks = @(Get-ChildItem -LiteralPath (Join-Path $root 'audio/music') -Filter '*.ogg').Count
        voice_clips = @(Get-ChildItem -LiteralPath (Join-Path $root 'audio/voice') -Filter 'el_*.mp3').Count
        executable_sha256 = (Get-FileHash -LiteralPath $exe -Algorithm SHA256).Hash
        bytes = (Get-Item -LiteralPath $exe).Length
    }
    $manifest | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath (Join-Path $package 'build-manifest.json') -Encoding UTF8
    Compress-Archive -LiteralPath $package -DestinationPath $zip -CompressionLevel Optimal
    Write-Output "Package: $zip"
    Write-Output "SHA256: $((Get-FileHash -LiteralPath $zip -Algorithm SHA256).Hash)"
} finally {
    $env:APPDATA = $sourceProfile
}
