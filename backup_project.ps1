param(
    [string]$Source = "c:\goh\test\goh_calculator\flutter_application",
    [string]$DestinationRoot = "D:\backup",
    [switch]$IncludeGit
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path $Source)) {
    throw "Source path not found: $Source"
}

if (-not (Test-Path $DestinationRoot)) {
    New-Item -ItemType Directory -Path $DestinationRoot | Out-Null
}

$projectName = Split-Path $Source -Leaf
$destination = Join-Path $DestinationRoot $projectName

if (-not (Test-Path $destination)) {
    New-Item -ItemType Directory -Path $destination | Out-Null
}

# Save VS Code extensions list if 'code' command is available.
$codeCmd = Get-Command code -ErrorAction SilentlyContinue
if ($null -ne $codeCmd) {
    $extFile = Join-Path $destination "extensions.txt"
    code --list-extensions | Set-Content -Encoding UTF8 $extFile
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

Write-Host "Backing up from: $Source"
Write-Host "Backing up to  : $destination"
Write-Host "Excluded dirs  : $($excludeDirs -join ', ')"

$cmdArgs = @(
    "`"$Source`"",
    "`"$destination`"",
    "/MIR",
    "/R:2",
    "/W:2",
    "/XD"
) + $excludeDirs

$cmdLine = "robocopy " + ($cmdArgs -join " ")
Write-Host $cmdLine

$null = Invoke-Expression $cmdLine
$exitCode = $LASTEXITCODE

# Robocopy exit code <= 7 is generally success/acceptable differences.
if ($exitCode -gt 7) {
    throw "Robocopy failed with exit code $exitCode"
}

Write-Host "Backup completed successfully. Robocopy exit code: $exitCode"
Write-Host "Destination: $destination"
