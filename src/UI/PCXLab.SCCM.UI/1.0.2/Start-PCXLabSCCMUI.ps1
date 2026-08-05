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

# Load essential UI functions from the selected version
. (Join-Path $VersionPath "Functions\Import-PCXLabSCCMModule.ps1")
. (Join-Path $VersionPath "Functions\Initialize-PCXLabSCCMUI.ps1")

try {

    #Write-Host "Initializing PCXLab SCCM Unified Tool (v$Version)..." -ForegroundColor Cyan
    Write-Host "Initializing PCXLab SCCM Application Manager v$Version..." -ForegroundColor Cyan

    # Make version globally available to UI
    $script:PCXUIVersion = $Version

    # Load module and validate requirements
    [void](Initialize-PCXLabSCCMUI)

    # Launch UI
    & (Join-Path $VersionPath "Scripts\UnifiedWindow.ps1")
}
catch {
    [System.Windows.MessageBox]::Show(
        $_.Exception.Message,
        "Startup Error"
    )

    Write-Error $_.Exception.Message
}