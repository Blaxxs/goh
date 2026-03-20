param(
    [string]$BackupRoot = "D:\backup",
    [string]$Target = "c:\goh\test\goh_calculator\flutter_application",
    [switch]$IncludeGit,
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"

$projectName = Split-Path $Target -Leaf
$source = Join-Path $BackupRoot $projectName

if (-not (Test-Path $source)) {
    throw "Backup source path not found: $source"
}

if (-not (Test-Path $Target)) {
    New-Item -ItemType Directory -Path $Target | Out-Null
}

$excludeDirs = @(
    "build",
    ".dart_tool",
    "android\.gradle",
    "ios\Pods"
)

if (-not $IncludeGit) {
    $excludeDirs += ".git"
}

Write-Host "Restoring from: $source"
Write-Host "Restoring to  : $Target"
Write-Host "Excluded dirs : $($excludeDirs -join ', ')"

$cmdArgs = @(
    "`"$source`"",
    "`"$Target`"",
    "/MIR",
    "/R:2",
    "/W:2",
    "/XD"
) + $excludeDirs

if ($DryRun) {
    $cmdArgs += "/L"
}

$cmdLine = "robocopy " + ($cmdArgs -join " ")
Write-Host $cmdLine

$null = Invoke-Expression $cmdLine
$exitCode = $LASTEXITCODE

# Robocopy exit code <= 7 is generally success/acceptable differences.
if ($exitCode -gt 7) {
    throw "Restore failed with robocopy exit code $exitCode"
}

if ($DryRun) {
    Write-Host "Dry run completed. Robocopy exit code: $exitCode"
} else {
    Write-Host "Restore completed successfully. Robocopy exit code: $exitCode"
}
