# New-PCXCMAutomation.ps1
# V3 Professional Bootstrap Script
# Creates clean enterprise structure:
#
# PCXCMAutomation\
# ├── src\
# │   ├── Modules\
# │   ├── Automations\
# │   └── Runbooks\
# ├── config\
# ├── docs\
# ├── ops\
# ├── tests\
# ├── .github\
# ├── README.md
# ├── CHANGELOG.md
# └── LICENSE

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
# Helpers
# ------------------------------------------------------------
function New-PCXFolder {
    param([string]$Path)

    if (-not (Test-Path $Path)) {
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
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
# Folder Blueprint
# ------------------------------------------------------------
$Folders = @(
    $ProjectRoot,

    # Root Zones
    "$ProjectRoot\src",
    "$ProjectRoot\config",
    "$ProjectRoot\docs",
    "$ProjectRoot\ops",
    "$ProjectRoot\tests",
    "$ProjectRoot\.github\workflows",

    # src
    "$ProjectRoot\src\Modules",
    "$ProjectRoot\src\Automations",
    "$ProjectRoot\src\Runbooks",

    # Modules
    "$ProjectRoot\src\Modules\PCXLab.Core",
    "$ProjectRoot\src\Modules\PCXLab.SCCM",

    # Automations
    "$ProjectRoot\src\Automations\Applications",
    "$ProjectRoot\src\Automations\Packages",
    "$ProjectRoot\src\Automations\Collections",
    "$ProjectRoot\src\Automations\SoftwareUpdates",
    "$ProjectRoot\src\Automations\Devices",
    "$ProjectRoot\src\Automations\OSD",
    "$ProjectRoot\src\Automations\Reporting",

    # Runbooks
    "$ProjectRoot\src\Runbooks\Daily",
    "$ProjectRoot\src\Runbooks\Weekly",
    "$ProjectRoot\src\Runbooks\Monthly",
    "$ProjectRoot\src\Runbooks\Emergency",
    "$ProjectRoot\src\Runbooks\Onboarding",

    # config
    "$ProjectRoot\config\environments",

    # docs
    "$ProjectRoot\docs\notes",
    "$ProjectRoot\docs\templates",
    "$ProjectRoot\docs\architecture",

    # ops
    "$ProjectRoot\ops\logs",
    "$ProjectRoot\ops\reports",
    "$ProjectRoot\ops\scripts",
    "$ProjectRoot\ops\artifacts",

    # tests
    "$ProjectRoot\tests\Unit",
    "$ProjectRoot\tests\Integration",
    "$ProjectRoot\tests\Regression"
)

# ------------------------------------------------------------
# Create folders
# ------------------------------------------------------------
Write-Host "Creating professional project structure..." -ForegroundColor Cyan

foreach ($Folder in $Folders) {
    New-PCXFolder $Folder
}

# ------------------------------------------------------------
# Root Files
# ------------------------------------------------------------
Set-PCXFile "$ProjectRoot\README.md" @"
# PCXCMAutomation

Professional PowerShell automation platform for SCCM / MECM.

## Structure

- src        = code
- config     = settings
- docs       = documentation
- ops        = logs / reports / scripts
- tests      = validation
"@

Set-PCXFile "$ProjectRoot\CHANGELOG.md" @"
# Changelog

## [1.0.0]
- Professional bootstrap structure created
"@

Set-PCXFile "$ProjectRoot\LICENSE" "MIT License"

# ------------------------------------------------------------
# Config Files
# ------------------------------------------------------------
Set-PCXFile "$ProjectRoot\config\GlobalSettings.json" @'
{
  "LoggingEnabled": true,
  "Environment": "Dev"
}
'@

Set-PCXFile "$ProjectRoot\config\environments\Dev.json" @'
{
  "SiteCode": "P01",
  "ProviderMachine": "SCCMDEV01"
}
'@

Set-PCXFile "$ProjectRoot\config\environments\Test.json" @'
{
  "SiteCode": "T01",
  "ProviderMachine": "SCCMTEST01"
}
'@

Set-PCXFile "$ProjectRoot\config\environments\Prod.json" @'
{
  "SiteCode": "PR1",
  "ProviderMachine": "SCCMPROD01"
}
'@

# ------------------------------------------------------------
# Docs
# ------------------------------------------------------------
Set-PCXFile "$ProjectRoot\docs\GettingStarted.md" @"
# Getting Started

1. Build / import modules under src\Modules
2. Store workflows under src\Automations
3. Store scheduled operations under src\Runbooks
"@

Set-PCXFile "$ProjectRoot\docs\architecture\Overview.md" @"
# Architecture

Modules     = reusable functions
Automations = workflows
Runbooks    = orchestrations
"@

Set-PCXFile "$ProjectRoot\docs\templates\AutomationTemplate.ps1" @'
Import-Module PCXLab.Core
Import-Module PCXLab.SCCM

Connect-PCXCMSite
Write-Host "Automation Started"
'@

# ------------------------------------------------------------
# Ops Scripts
# ------------------------------------------------------------
Set-PCXFile "$ProjectRoot\ops\scripts\BuildRelease.ps1" @'
Write-Host "Build release placeholder"
'@

Set-PCXFile "$ProjectRoot\ops\scripts\TestAll.ps1" @'
Write-Host "Run all tests placeholder"
'@

Set-PCXFile "$ProjectRoot\ops\scripts\SignScripts.ps1" @'
Write-Host "Code signing placeholder"
'@

# ------------------------------------------------------------
# Example Automations
# ------------------------------------------------------------
Set-PCXFile "$ProjectRoot\src\Automations\Applications\Deploy-Chrome.ps1" @'
Write-Host "Deploy Chrome automation"
'@

Set-PCXFile "$ProjectRoot\src\Automations\Collections\Create-MonthlyCollections.ps1" @'
Write-Host "Create monthly collections"
'@

# ------------------------------------------------------------
# Example Runbooks
# ------------------------------------------------------------
Set-PCXFile "$ProjectRoot\src\Runbooks\Monthly\PatchTuesday.ps1" @'
Write-Host "Monthly patch runbook"
'@

Set-PCXFile "$ProjectRoot\src\Runbooks\Emergency\Remove-VulnerableApp.ps1" @'
Write-Host "Emergency removal runbook"
'@

# ------------------------------------------------------------
# Finish
# ------------------------------------------------------------
Write-Host ""
Write-Host "=========================================" -ForegroundColor Green
Write-Host "PCXCMAutomation Professional Structure Ready" -ForegroundColor Green
Write-Host "Path: $ProjectRoot" -ForegroundColor Yellow
Write-Host "=========================================" -ForegroundColor Green