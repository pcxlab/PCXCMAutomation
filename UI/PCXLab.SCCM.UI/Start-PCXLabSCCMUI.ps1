#Requires -Version 5.1

param(
    [string]$Version
)

Add-Type -AssemblyName PresentationFramework

$ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path

# Auto-detect latest version if not specified
if ([string]::IsNullOrWhiteSpace($Version)) {

    $LatestVersionFolder = Get-ChildItem -Path $ScriptRoot -Directory |
        Where-Object { $_.Name -match '^\d+\.\d+\.\d+$' } |
        Sort-Object { [version]$_.Name } |
        Select-Object -Last 1

    if (-not $LatestVersionFolder) {
        [System.Windows.MessageBox]::Show(
            "No version folders found.",
            "Launch Error"
        )
        return
    }

    $Version = $LatestVersionFolder.Name
}

$VersionPath = Join-Path $ScriptRoot $Version

if (-not (Test-Path $VersionPath)) {
    [System.Windows.MessageBox]::Show(
        "UI Version '$Version' not found at: $VersionPath",
        "Launch Error"
    )
    return
}

# Hand off execution to version bootstrap
$AppBootstrapPath = Join-Path $VersionPath "App.ps1"

if (-not (Test-Path $AppBootstrapPath)) {
    [System.Windows.MessageBox]::Show(
        "Application bootstrap file 'App.ps1' not found at: $AppBootstrapPath",
        "Launch Error"
    )
    return
}

# Make version globally available to UI
$script:PCXUIVersion = $Version

& $AppBootstrapPath