#Requires -Version 5.1

param(
    [string]$Version = "1.0.0"
)

Add-Type -AssemblyName PresentationFramework

$ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$VersionPath = Join-Path $ScriptRoot $Version

if (-not (Test-Path $VersionPath)) {
    [System.Windows.MessageBox]::Show("UI Version '$Version' not found at: $VersionPath", "Launch Error")
    return
}

# Load essential UI functions from the specific version
. (Join-Path $VersionPath "Functions\Import-PCXLabSCCMModule.ps1")
. (Join-Path $VersionPath "Functions\Initialize-PCXLabSCCMUI.ps1")

try {
    Write-Host "Initializing PCXLab SCCM Unified Tool (v$Version)..." -ForegroundColor Cyan
    
    # Load module and validate requirements
    [void](Initialize-PCXLabSCCMUI)
    
    # Launch the unified window script from the specific version folder
    & (Join-Path $VersionPath "Scripts\UnifiedWindow.ps1")
}
catch {
    [System.Windows.MessageBox]::Show($_.Exception.Message, "Startup Error")
    Write-Error $_.Exception.Message
}