# New-PCXCMAutomation.ps1
# V4.4 Audited Final Baseline
# Merged + Cross-checked:
# - V4.2 completeness
# - V4.3 GitHub + Tools
# - Versioned modules
# - Guidance files
# - Long-term maintainable scaffold

[CmdletBinding()]
param(
    [string]$ProjectName = "PCXCMAutomation",
    [string]$BasePath,
    [string]$Author = "PCXLab"
)

# ------------------------------------------------------------
# BasePath
# ------------------------------------------------------------
if ([string]::IsNullOrWhiteSpace($BasePath)) {
    if ($PSScriptRoot) { $BasePath = $PSScriptRoot }
    else { $BasePath = (Get-Location).Path }
}

# ------------------------------------------------------------
# Constants
# ------------------------------------------------------------
$Versions = @("dev","0.0.0","0.1.0")
$ProjectRoot = Join-Path $BasePath $ProjectName
$SrcRoot     = Join-Path $ProjectRoot "src"
$ModulesRoot = Join-Path $SrcRoot "Modules"

$SCCMDomains = @(
    "Connection","Collections","Devices","Applications","Packages",
    "Queries","Folders","SoftwareUpdates","TaskSequences",
    "OSD","Drivers","Baselines","Utilities"
)

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

function New-PCXManifest {
    param(
        [string]$Path,
        [string]$RootModule,
        [string]$Version,
        [object]$FunctionsToExport,
        [string]$Description
    )

    New-ModuleManifest `
        -Path $Path `
        -RootModule $RootModule `
        -ModuleVersion $Version `
        -Author $Author `
        -CompanyName $Author `
        -PowerShellVersion "5.1" `
        -Description $Description `
        -FunctionsToExport $FunctionsToExport `
        -AliasesToExport @() `
        -CmdletsToExport @() `
        -VariablesToExport @() | Out-Null
}

function New-PCXLoader {
    param([string]$Path)

$Loader = @'
# Auto-load Private
Get-ChildItem "$PSScriptRoot\Private\*.ps1" -Recurse -ErrorAction SilentlyContinue |
Sort-Object FullName | ForEach-Object { . $_.FullName }

# Auto-load Classes
Get-ChildItem "$PSScriptRoot\Classes\*.ps1" -Recurse -ErrorAction SilentlyContinue |
Sort-Object FullName | ForEach-Object { . $_.FullName }

# Auto-load Public
Get-ChildItem "$PSScriptRoot\Public\*.ps1" -Recurse -ErrorAction SilentlyContinue |
Sort-Object FullName | ForEach-Object { . $_.FullName }
'@

    Set-PCXFile $Path $Loader
}

# ------------------------------------------------------------
# Root Folders
# ------------------------------------------------------------
$Folders = @(
    $ProjectRoot,

    "$ProjectRoot\src",
    "$ProjectRoot\config",
    "$ProjectRoot\docs",
    "$ProjectRoot\ops",
    "$ProjectRoot\tests",
    "$ProjectRoot\tools",
    "$ProjectRoot\.github",

    "$ProjectRoot\.github\workflows",
    "$ProjectRoot\.github\ISSUE_TEMPLATE",

    "$ProjectRoot\src\Modules",
    "$ProjectRoot\src\Automations",
    "$ProjectRoot\src\Runbooks",

    "$ProjectRoot\src\Automations\Applications",
    "$ProjectRoot\src\Automations\Packages",
    "$ProjectRoot\src\Automations\Collections",
    "$ProjectRoot\src\Automations\SoftwareUpdates",
    "$ProjectRoot\src\Automations\Devices",
    "$ProjectRoot\src\Automations\OSD",
    "$ProjectRoot\src\Automations\Reporting",

    "$ProjectRoot\src\Runbooks\Daily",
    "$ProjectRoot\src\Runbooks\Weekly",
    "$ProjectRoot\src\Runbooks\Monthly",
    "$ProjectRoot\src\Runbooks\Emergency",
    "$ProjectRoot\src\Runbooks\Onboarding",

    "$ProjectRoot\config\environments",

    "$ProjectRoot\docs\notes",
    "$ProjectRoot\docs\templates",
    "$ProjectRoot\docs\architecture",

    "$ProjectRoot\ops\logs",
    "$ProjectRoot\ops\reports",
    "$ProjectRoot\ops\scripts",
    "$ProjectRoot\ops\artifacts",

    "$ProjectRoot\tests\Unit",
    "$ProjectRoot\tests\Integration",
    "$ProjectRoot\tests\Regression",

    "$ProjectRoot\tools\bootstrap",
    "$ProjectRoot\tools\signing",
    "$ProjectRoot\tools\packaging",
    "$ProjectRoot\tools\helpers"
)

Write-Host "Creating V4.4 scaffold..." -ForegroundColor Cyan
foreach ($Folder in $Folders) { New-PCXFolder $Folder }

# ------------------------------------------------------------
# Modules
# ------------------------------------------------------------
$Modules = @("PCXLab.Core","PCXLab.SCCM")

foreach ($Module in $Modules) {

    foreach ($VersionFolder in $Versions) {

        $VersionNumber = if ($VersionFolder -eq "dev") { "0.0.0" } else { $VersionFolder }
        $ModuleRoot = Join-Path $ModulesRoot "$Module\$VersionFolder"

        New-PCXFolder $ModuleRoot
        New-PCXFolder (Join-Path $ModuleRoot "Private")
        New-PCXFolder (Join-Path $ModuleRoot "Classes")
        New-PCXFolder (Join-Path $ModuleRoot "Config")
        New-PCXFolder (Join-Path $ModuleRoot "Docs")
        New-PCXFolder (Join-Path $ModuleRoot "Tests")

        if ($Module -eq "PCXLab.Core") {
            New-PCXFolder (Join-Path $ModuleRoot "Public")
        }
        else {
            foreach ($Domain in $SCCMDomains) {
                New-PCXFolder (Join-Path $ModuleRoot "Public\$Domain")
            }
        }

        $Psm1 = "$Module.psm1"
        $Psd1 = "$Module.psd1"

        New-PCXLoader (Join-Path $ModuleRoot $Psm1)

        if ($Module -eq "PCXLab.Core") {
            $Exports = if ($VersionFolder -eq "dev") { "*" } else {
                @("Start-PCXLogSession","Write-PCXLog","Test-PCXEnvironment")
            }
        }
        else {
            $Exports = if ($VersionFolder -eq "dev") { "*" } else {
                @(
                    "Connect-PCXCMSite",
                    "Get-PCXCMSiteCode",
                    "Get-PCXCMProviderMachineName",
                    "Get-PCXCMDevice",
                    "Get-PCXCMCollection",
                    "New-PCXCMCollection"
                )
            }
        }

        New-PCXManifest `
            -Path (Join-Path $ModuleRoot $Psd1) `
            -RootModule $Psm1 `
            -Version $VersionNumber `
            -FunctionsToExport $Exports `
            -Description "$Module Module"

        Set-PCXFile (Join-Path $ModuleRoot "README.md") @"
# $Module - $VersionFolder

dev   = active development
0.0.0 = baseline prototype
0.1.0 = first stable release
"@
    }
}

# ------------------------------------------------------------
# Seed Core Functions (dev)
# ------------------------------------------------------------
Set-PCXFile "$ModulesRoot\PCXLab.Core\dev\Public\Start-PCXLogSession.ps1" @'
function Start-PCXLogSession {
    param([Parameter(Mandatory)][string]$LogFolder)
    Write-Host "Logging started at $LogFolder"
}
'@

Set-PCXFile "$ModulesRoot\PCXLab.Core\dev\Public\Write-PCXLog.ps1" @'
function Write-PCXLog {
    param([string]$Message)
    Write-Host $Message
}
'@

Set-PCXFile "$ModulesRoot\PCXLab.Core\dev\Public\Test-PCXEnvironment.ps1" @'
function Test-PCXEnvironment { return $true }
'@

# ------------------------------------------------------------
# Seed SCCM Functions (dev)
# ------------------------------------------------------------
Set-PCXFile "$ModulesRoot\PCXLab.SCCM\dev\Public\Connection\Connect-PCXCMSite.ps1" @'
function Connect-PCXCMSite { Write-Host "Connected to SCCM Site" }
'@

Set-PCXFile "$ModulesRoot\PCXLab.SCCM\dev\Public\Collections\New-PCXCMCollection.ps1" @'
function New-PCXCMCollection {
    param([string]$Name)
    Write-Host "Created collection $Name"
}
'@

Set-PCXFile "$ModulesRoot\PCXLab.SCCM\dev\Config\Settings.json" @'
{
  "SiteCode": "P01",
  "ProviderMachine": "SCCM01"
}
'@

# ------------------------------------------------------------
# Root Files
# ------------------------------------------------------------
Set-PCXFile "$ProjectRoot\README.md" @"
# PCXCMAutomation

Professional PowerShell automation platform for SCCM / MECM.

## Zones

- src
- config
- docs
- ops
- tests
- tools
- .github
"@

Set-PCXFile "$ProjectRoot\CHANGELOG.md" @"
# Changelog

## [4.4.0]
- Audited final baseline scaffold
"@

Set-PCXFile "$ProjectRoot\LICENSE" "MIT License"

Set-PCXFile "$ProjectRoot\.gitignore" @"
# Runtime outputs
ops/logs/
ops/reports/
ops/artifacts/

# Editors
.vscode/

# Temp
*.tmp
*.bak
"@

Set-PCXFile "$ProjectRoot\.editorconfig" @"
root = true

[*]
charset = utf-8
end_of_line = crlf
insert_final_newline = true
indent_style = space
indent_size = 4
"@

# ------------------------------------------------------------
# Docs
# ------------------------------------------------------------
Set-PCXFile "$ProjectRoot\docs\GettingStarted.md" @"
# Getting Started

## Development Module

Import-Module .\src\Modules\PCXLab.SCCM\dev\PCXLab.SCCM.psd1 -Force

## Stable Module

Import-Module .\src\Modules\PCXLab.SCCM\0.1.0\PCXLab.SCCM.psd1 -Force
"@

Set-PCXFile "$ProjectRoot\docs\NamingStandards.md" @"
# Naming Standards

PCX   = Core shared functions
PCXCM = SCCM functions

Use Verb-Noun naming.
"@

Set-PCXFile "$ProjectRoot\docs\architecture\Overview.md" @"
# Architecture

src    = source code
config = settings
docs   = documentation
ops    = operational outputs
tests  = validation
tools  = helper utilities
"@

Set-PCXFile "$ProjectRoot\docs\notes\README.md" @"
Use for:
- architecture notes
- ideas backlog
- design decisions
- meeting summaries
"@

Set-PCXFile "$ProjectRoot\docs\notes\DecisionLog.md" "# Decision Log"

Set-PCXFile "$ProjectRoot\docs\templates\AutomationTemplate.ps1" @'
Import-Module PCXLab.Core
Import-Module PCXLab.SCCM

Connect-PCXCMSite
Write-PCXLog -Message "Automation Started"
'@

Set-PCXFile "$ProjectRoot\docs\templates\RunbookTemplate.ps1" @'
Write-Host "Runbook Started"
'@

# ------------------------------------------------------------
# src Guidance
# ------------------------------------------------------------
Set-PCXFile "$ProjectRoot\src\Automations\README.md" @"
Reusable workflows:
- Deploy-Chrome.ps1
- Create-MonthlyCollections.ps1
"@

Set-PCXFile "$ProjectRoot\src\Runbooks\README.md" @"
Scheduled orchestration jobs:
- PatchTuesday.ps1
- Emergency-Removal.ps1
"@

# ------------------------------------------------------------
# Ops
# ------------------------------------------------------------
Set-PCXFile "$ProjectRoot\ops\logs\README.md" "Store runtime logs here."
Set-PCXFile "$ProjectRoot\ops\reports\README.md" "Store generated reports here."
Set-PCXFile "$ProjectRoot\ops\artifacts\README.md" "Store build artifacts here."

Set-PCXFile "$ProjectRoot\ops\scripts\README.md" "Project maintenance scripts only."
Set-PCXFile "$ProjectRoot\ops\scripts\BuildRelease.ps1" 'Write-Host "Build release"'
Set-PCXFile "$ProjectRoot\ops\scripts\TestAll.ps1" 'Write-Host "Run tests"'
Set-PCXFile "$ProjectRoot\ops\scripts\CleanWorkspace.ps1" 'Write-Host "Clean workspace"'

# ------------------------------------------------------------
# Tests
# ------------------------------------------------------------
Set-PCXFile "$ProjectRoot\tests\README.md" "Use Pester tests here."

Set-PCXFile "$ProjectRoot\tests\Unit\Sample.Tests.ps1" @'
Describe "Sample Test" {
    It "Should be true" {
        $true | Should -BeTrue
    }
}
'@

# ------------------------------------------------------------
# Config
# ------------------------------------------------------------
Set-PCXFile "$ProjectRoot\config\README.md" "Environment settings live here."

Set-PCXFile "$ProjectRoot\config\environments\Dev.json" @'
{
  "SiteCode": "P01",
  "ProviderMachine": "SCCMDEV01"
}
'@

Set-PCXFile "$ProjectRoot\config\environments\Prod.json" @'
{
  "SiteCode": "PR1",
  "ProviderMachine": "SCCMPROD01"
}
'@

# ------------------------------------------------------------
# Tools
# ------------------------------------------------------------
Set-PCXFile "$ProjectRoot\tools\README.md" @"
bootstrap = generators
signing   = code signing helpers
packaging = packaging helpers
helpers   = misc utilities
"@

Set-PCXFile "$ProjectRoot\tools\bootstrap\README.md" "Project generators."
Set-PCXFile "$ProjectRoot\tools\signing\README.md" "Certificate / signing tools."
Set-PCXFile "$ProjectRoot\tools\packaging\README.md" "Packaging tools."
Set-PCXFile "$ProjectRoot\tools\helpers\README.md" "Misc helper utilities."

# ------------------------------------------------------------
# GitHub
# ------------------------------------------------------------
Set-PCXFile "$ProjectRoot\.github\workflows\README.md" "Place CI/CD YAML files here."

Set-PCXFile "$ProjectRoot\.github\PULL_REQUEST_TEMPLATE.md" @"
## Summary

Describe changes.

## Validation

How was it tested?
"@

Set-PCXFile "$ProjectRoot\.github\ISSUE_TEMPLATE\bug_report.md" @"
---
name: Bug report
about: Report a defect
---

Describe the issue.
"@

Set-PCXFile "$ProjectRoot\.github\ISSUE_TEMPLATE\feature_request.md" @"
---
name: Feature request
about: Suggest an enhancement
---

Describe the request.
"@

Set-PCXFile "$ProjectRoot\.github\CODEOWNERS" "* @$Author"

# ------------------------------------------------------------
# Finish
# ------------------------------------------------------------
Write-Host ""
Write-Host "=========================================" -ForegroundColor Green
Write-Host "PCXCMAutomation V4.4 Ready" -ForegroundColor Green
Write-Host "Path: $ProjectRoot" -ForegroundColor Yellow
Write-Host "=========================================" -ForegroundColor Green