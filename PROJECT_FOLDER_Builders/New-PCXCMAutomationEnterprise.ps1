# New-PCXCMAutomationEnterprise.ps1
# Creates full enterprise-ready PCXCMAutomation folder structure

[CmdletBinding()]
param(
    [string]$ProjectName = "PCXCMAutomation",
    [string]$BasePath
)

# ------------------------------------------------------------
# BasePath fallback
# ------------------------------------------------------------
if ([string]::IsNullOrWhiteSpace($BasePath)) {
    if ($PSScriptRoot) {
        $BasePath = $PSScriptRoot
    }
    else {
        $BasePath = (Get-Location).Path
    }
}

# ------------------------------------------------------------
# Paths
# ------------------------------------------------------------
$ProjectRoot = Join-Path $BasePath $ProjectName

# ------------------------------------------------------------
# Helper
# ------------------------------------------------------------
function New-PCXFolder {
    param([string]$Path)

    if (-not (Test-Path $Path)) {
        New-Item -Path $Path -ItemType Directory -Force | Out-Null
    }
}

function Set-PCXFile {
    param(
        [string]$Path,
        [string]$Content
    )

    $Parent = Split-Path $Path -Parent
    New-PCXFolder $Parent
    Set-Content -Path $Path -Value $Content -Encoding UTF8
}

# ------------------------------------------------------------
# Full Folder Blueprint
# ------------------------------------------------------------
$Folders = @(
    $ProjectRoot,

    # Core product areas
    "$ProjectRoot\Modules",
    "$ProjectRoot\Automations",
    "$ProjectRoot\Runbooks",
    "$ProjectRoot\Templates",
    "$ProjectRoot\Config",
    "$ProjectRoot\Logs",
    "$ProjectRoot\Reports",
    "$ProjectRoot\Scripts",
    "$ProjectRoot\Docs",
    "$ProjectRoot\Tests",
    "$ProjectRoot\.github\workflows",

    # Modules
    "$ProjectRoot\Modules\PCXLab.Core",
    "$ProjectRoot\Modules\PCXLab.SCCM",

    # Automations
    "$ProjectRoot\Automations\Applications",
    "$ProjectRoot\Automations\Packages",
    "$ProjectRoot\Automations\Collections",
    "$ProjectRoot\Automations\SoftwareUpdates",
    "$ProjectRoot\Automations\Devices",
    "$ProjectRoot\Automations\OSD",
    "$ProjectRoot\Automations\Reporting",

    # Runbooks
    "$ProjectRoot\Runbooks\Daily",
    "$ProjectRoot\Runbooks\Weekly",
    "$ProjectRoot\Runbooks\Monthly",
    "$ProjectRoot\Runbooks\Emergency",
    "$ProjectRoot\Runbooks\Onboarding",

    # Logs
    "$ProjectRoot\Logs\Automations",
    "$ProjectRoot\Logs\Runbooks",

    # Reports
    "$ProjectRoot\Reports\HTML",
    "$ProjectRoot\Reports\CSV",
    "$ProjectRoot\Reports\Excel",

    # Tests
    "$ProjectRoot\Tests\Unit",
    "$ProjectRoot\Tests\Integration",
    "$ProjectRoot\Tests\Regression"
)

# ------------------------------------------------------------
# Create folders
# ------------------------------------------------------------
Write-Host "Creating enterprise structure..." -ForegroundColor Cyan

foreach ($Folder in $Folders) {
    New-PCXFolder $Folder
}

# ------------------------------------------------------------
# Create starter files
# ------------------------------------------------------------

# Root Docs
Set-PCXFile "$ProjectRoot\README.md" @"
# PCXCMAutomation

Enterprise PowerShell automation platform for SCCM / MECM.

## Main Areas

- Modules
- Automations
- Runbooks
- Config
- Logs
- Reports
- Tests
"@

Set-PCXFile "$ProjectRoot\CHANGELOG.md" @"
# Changelog

## [0.1.0]
- Enterprise project structure created
"@

Set-PCXFile "$ProjectRoot\LICENSE" "MIT License"

# Docs
Set-PCXFile "$ProjectRoot\Docs\GettingStarted.md" @"
# Getting Started

1. Build or import modules
2. Use Automations for workflows
3. Use Runbooks for scheduled operations
"@

Set-PCXFile "$ProjectRoot\Docs\Architecture.md" @"
# Architecture

Modules = reusable functions  
Automations = workflows  
Runbooks = operations orchestration
"@

Set-PCXFile "$ProjectRoot\Docs\NamingStandards.md" @"
# Naming Standards

Core functions   = PCX prefix  
SCCM functions   = PCXCM prefix
"@

# Config
Set-PCXFile "$ProjectRoot\Config\GlobalSettings.json" @'
{
  "Environment": "Dev",
  "LoggingEnabled": true
}
'@

Set-PCXFile "$ProjectRoot\Config\Dev.json" @'
{
  "SiteCode": "P01",
  "ProviderMachine": "SCCM01"
}
'@

Set-PCXFile "$ProjectRoot\Config\Test.json" @'
{
  "SiteCode": "T01",
  "ProviderMachine": "SCCMTEST01"
}
'@

Set-PCXFile "$ProjectRoot\Config\Prod.json" @'
{
  "SiteCode": "PR1",
  "ProviderMachine": "SCCMPROD01"
}
'@

# Templates
Set-PCXFile "$ProjectRoot\Templates\AutomationTemplate.ps1" @'
Import-Module PCXLab.Core
Import-Module PCXLab.SCCM

Connect-PCXCMSite
Write-PCXLog -Message "Automation started"
'@

Set-PCXFile "$ProjectRoot\Templates\RunbookTemplate.ps1" @'
# Example runbook
Write-Host "Runbook started"
'@

# Scripts
Set-PCXFile "$ProjectRoot\Scripts\BuildRelease.ps1" @'
Write-Host "Build release pipeline placeholder"
'@

Set-PCXFile "$ProjectRoot\Scripts\TestAll.ps1" @'
Write-Host "Run all tests placeholder"
'@

Set-PCXFile "$ProjectRoot\Scripts\SignScripts.ps1" @'
Write-Host "Code signing placeholder"
'@

# Example Automations
Set-PCXFile "$ProjectRoot\Automations\Applications\Deploy-Chrome.ps1" @'
Import-Module PCXLab.Core
Import-Module PCXLab.SCCM

Connect-PCXCMSite
Write-Host "Deploy Chrome"
'@

Set-PCXFile "$ProjectRoot\Automations\Collections\Create-MonthlyCollections.ps1" @'
Write-Host "Create monthly collections"
'@

# Example Runbooks
Set-PCXFile "$ProjectRoot\Runbooks\Monthly\PatchTuesday.ps1" @'
Write-Host "Monthly patching runbook"
'@

Set-PCXFile "$ProjectRoot\Runbooks\Emergency\Remove-VulnerableApp.ps1" @'
Write-Host "Emergency software removal runbook"
'@

# ------------------------------------------------------------
# Finish
# ------------------------------------------------------------
Write-Host ""
Write-Host "=========================================" -ForegroundColor Green
Write-Host "PCXCMAutomation Enterprise Structure Ready" -ForegroundColor Green
Write-Host "Path: $ProjectRoot" -ForegroundColor Yellow
Write-Host "=========================================" -ForegroundColor Green