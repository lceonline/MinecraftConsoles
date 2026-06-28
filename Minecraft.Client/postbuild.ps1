param(
    [string]$OutDir,
    [string]$ProjectDir
)

Write-Host "Post-build script started. Output Directory: $OutDir, Project Directory: $ProjectDir"

$directories = @(
    "Windows64\GameHDD",
    "Windows64Media\Music",
    "Common\Media",
    "Common\res",
    "Windows64Media"
)

foreach ($dir in $directories) {
    New-Item -ItemType Directory -Path (Join-Path $OutDir $dir) -Force | Out-Null
}

$copies = @(
    @{ Source = "Music\MiniAudio";   Dest = "Windows64Media\Music" },
    @{ Source = "Common\Media";      Dest = "Common\Media" },
    @{ Source = "Common\res";        Dest = "Common\res" },
    @{ Source = "Windows64\GameHDD"; Dest = "Windows64\GameHDD" },
    @{ Source = "Windows64Media";    Dest = "Windows64Media" }
)

foreach ($copy in $copies) {
    $src = Join-Path $ProjectDir $copy.Source
    $dst = Join-Path $OutDir $copy.Dest

    if (Test-Path $src) {
        # Copy the files using xcopy, forcing overwrite and suppressing errors, and only copying if the source is newer than the destination
        xcopy /q /y /i /s /e /d "$src" "$dst" 2>$null
    }
}

$deleteDirs = @(
    "Common\Media\Sound",
    "Common\Media\Graphics",
    "Common\Media\font"
)

foreach ($dir in $deleteDirs) {
    $path = Join-Path $OutDir $dir
    if (Test-Path $path) {
        Remove-Item $path -Recurse -Force -ErrorAction SilentlyContinue
    }
}

$delDir = Join-Path $OutDir "Common\Media"

if (Test-Path $delDir) {
    Get-ChildItem -Path "$delDir\*" -Recurse -Include *.swf,*.txt,*.resx,*.xml,*.loc,*.lang,*.col -File |
        Remove-Item -Force -ErrorAction SilentlyContinue
}