# =====================================================================
# New-PCXCMAutomation.ps1
# Version 5.0 Final Rewrite
#
# Clean, audited, long-term scaffold for PCXCMAutomation
# Includes:
# - src / config / docs / ops / tests / tools / .github
# - Versioned modules (Option A)
# - PCXLab.Core + PCXLab.SCCM
# - Guidance files
# - Templates
# - GitHub repo hygiene
# - Ready for years of growth
# =====================================================================

[CmdletBinding()]
param(
    [string]$ProjectName = "PCXCMAutomation",
    [string]$BasePath,
    [string]$Author = "PCXLab"
)

# ---------------------------------------------------------------------
# BasePath
# ---------------------------------------------------------------------
if ([string]::IsNullOrWhiteSpace($BasePath)) {
    if ($PSScriptRoot) { $BasePath = $PSScriptRoot }
    else { $BasePath = (Get-Location).Path }
}

# ---------------------------------------------------------------------
# Constants
# ---------------------------------------------------------------------
$ProjectRoot = Join-Path $BasePath $ProjectName
$ModulesRoot = Join-Path $ProjectRoot "src\Modules"

$Versions = @("dev","0.0.0","0.1.0")

$SCCMDomains = @(
    "Connection","Collections","Devices","Applications","Packages",
    "Queries","Folders","SoftwareUpdates","TaskSequences",
    "OSD","Drivers","Baselines","Utilities"
)

# ---------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------
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

function New-PCXLoader {
    param([string]$Path)

$Content = @'
# Load Private
Get-ChildItem "$PSScriptRoot\Private\*.ps1" -Recurse -ErrorAction SilentlyContinue |
Sort-Object FullName | ForEach-Object { . $_.FullName }

# Load Classes
Get-ChildItem "$PSScriptRoot\Classes\*.ps1" -Recurse -ErrorAction SilentlyContinue |
Sort-Object FullName | ForEach-Object { . $_.FullName }

# Load Public
Get-ChildItem "$PSScriptRoot\Public\*.ps1" -Recurse -ErrorAction SilentlyContinue |
Sort-Object FullName | ForEach-Object { . $_.FullName }
'@

    Set-PCXFile $Path $Content
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

# ---------------------------------------------------------------------
# Root Folder Layout
# ---------------------------------------------------------------------
$Folders = @(
    $ProjectRoot,

    "$ProjectRoot\src",
    "$ProjectRoot\config",
    "$ProjectRoot\docs",
    "$ProjectRoot\ops",
    "$ProjectRoot\tests",
    "$ProjectRoot\tools",
    "$ProjectRoot\.github",

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
    "$ProjectRoot\tools\helpers",

    "$ProjectRoot\.github\workflows",
    "$ProjectRoot\.github\ISSUE_TEMPLATE"
)

Write-Host "Creating V5 scaffold..." -ForegroundColor Cyan
foreach ($Folder in $Folders) { New-PCXFolder $Folder }

# ---------------------------------------------------------------------
# Build Modules
# ---------------------------------------------------------------------
$Modules = @("PCXLab.Core","PCXLab.SCCM")

foreach ($Module in $Modules) {

    foreach ($VersionFolder in $Versions) {

        $VersionNumber = if ($VersionFolder -eq "dev") { "0.0.0" } else { $VersionFolder }
        $ModuleRoot = Join-Path $ModulesRoot "$Module\$VersionFolder"

        New-PCXFolder "$ModuleRoot\Public"
        New-PCXFolder "$ModuleRoot\Private"
        New-PCXFolder "$ModuleRoot\Classes"
        New-PCXFolder "$ModuleRoot\Config"
        New-PCXFolder "$ModuleRoot\Docs"
        New-PCXFolder "$ModuleRoot\Tests"

        if ($Module -eq "PCXLab.SCCM") {
            foreach ($Domain in $SCCMDomains) {
                New-PCXFolder "$ModuleRoot\Public\$Domain"
            }
        }

        $psm1 = "$Module.psm1"
        $psd1 = "$Module.psd1"

        New-PCXLoader "$ModuleRoot\$psm1"

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
            -Path "$ModuleRoot\$psd1" `
            -RootModule $psm1 `
            -Version $VersionNumber `
            -FunctionsToExport $Exports `
            -Description "$Module module"

        # Version Notes
        Set-PCXFile "$ModuleRoot\README.md" @"
# $Module - $VersionFolder

dev   = active development
0.0.0 = baseline prototype
0.1.0 = early stable release
"@

        # -------------------------------------------------------------
        # CORE CONTENT
        # -------------------------------------------------------------
        if ($Module -eq "PCXLab.Core") {

Set-PCXFile "$ModuleRoot\Public\Start-PCXLogSession.ps1" @'
function Start-PCXLogSession {
    param([Parameter(Mandatory)][string]$LogFolder)

    if (-not (Test-Path $LogFolder)) {
        New-Item -Path $LogFolder -ItemType Directory -Force | Out-Null
    }

    $Stamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $global:PCXLabLogFile = Join-Path $LogFolder "Run_$Stamp.log"

    New-Item -Path $global:PCXLabLogFile -ItemType File -Force | Out-Null
    Write-Host "Logging started: $global:PCXLabLogFile"
}
'@

Set-PCXFile "$ModuleRoot\Public\Write-PCXLog.ps1" @'
function Write-PCXLog {
    param(
        [Parameter(Mandatory)][string]$Message,
        [string]$Level = "INFO"
    )

    if (-not $global:PCXLabLogFile) {
        throw "Use Start-PCXLogSession first."
    }

    $Time = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $Line = "$Time [$Level] $Message"

    Add-Content -Path $global:PCXLabLogFile -Value $Line
    Write-Host $Line
}
'@

Set-PCXFile "$ModuleRoot\Public\Test-PCXEnvironment.ps1" @'
function Test-PCXEnvironment {
    [CmdletBinding()]
    param()
    return $true
}
'@

Set-PCXFile "$ModuleRoot\Private\Get-PCXTimestamp.ps1" @'
function Get-PCXTimestamp {
    Get-Date -Format "yyyyMMdd_HHmmss"
}
'@

Set-PCXFile "$ModuleRoot\Private\Resolve-PCXPath.ps1" @'
function Resolve-PCXPath {
    param([string]$Path)
    (Resolve-Path $Path).Path
}
'@

Set-PCXFile "$ModuleRoot\Docs\Examples.md" @"
# Examples

Start-PCXLogSession -LogFolder .\Logs
Write-PCXLog -Message 'Started'
"@

Set-PCXFile "$ModuleRoot\Tests\Core.Tests.ps1" @'
Describe "PCXLab.Core" {
    It "Should pass sample test" {
        $true | Should -BeTrue
    }
}
'@
        }

        # -------------------------------------------------------------
        # SCCM CONTENT
        # -------------------------------------------------------------
        if ($Module -eq "PCXLab.SCCM") {

Set-PCXFile "$ModuleRoot\Public\Connection\Connect-PCXCMSite.ps1" @'
function Connect-PCXCMSite {
    Write-Host "Connected to SCCM Site"
}
'@

Set-PCXFile "$ModuleRoot\Public\Connection\Get-PCXCMSiteCode.ps1" @'
function Get-PCXCMSiteCode { "P01" }
'@

Set-PCXFile "$ModuleRoot\Public\Connection\Get-PCXCMProviderMachineName.ps1" @'
function Get-PCXCMProviderMachineName { $env:COMPUTERNAME }
'@

Set-PCXFile "$ModuleRoot\Public\Collections\Get-PCXCMCollection.ps1" @'
function Get-PCXCMCollection {
    param([string]$Name)
    Write-Host "Collection: $Name"
}
'@

Set-PCXFile "$ModuleRoot\Public\Collections\New-PCXCMCollection.ps1" @'
function New-PCXCMCollection {
    param([string]$Name)
    Write-Host "Created collection: $Name"
}
'@

Set-PCXFile "$ModuleRoot\Public\Devices\Get-PCXCMDevice.ps1" @'
function Get-PCXCMDevice {
    param([string]$Name)
    Write-Host "Device: $Name"
}
'@

Set-PCXFile "$ModuleRoot\Config\Settings.json" @'
{
  "SiteCode": "P01",
  "ProviderMachine": "SCCM01"
}
'@

Set-PCXFile "$ModuleRoot\Docs\Examples.md" @"
# Examples

Connect-PCXCMSite
Get-PCXCMDevice -Name PC001
New-PCXCMCollection -Name TestCollection
"@

Set-PCXFile "$ModuleRoot\Tests\SCCM.Tests.ps1" @'
Describe "PCXLab.SCCM" {
    It "Should pass sample test" {
        $true | Should -BeTrue
    }
}
'@
        }
    }
}

# ---------------------------------------------------------------------
# Root Files
# ---------------------------------------------------------------------
Set-PCXFile "$ProjectRoot\README.md" @"
# PCXCMAutomation

Professional PowerShell automation platform for SCCM / MECM.
"@

Set-PCXFile "$ProjectRoot\CHANGELOG.md" @"
# Changelog

## [5.0.0]
- Final rewrite baseline created
"@

Set-PCXFile "$ProjectRoot\LICENSE" "MIT License"

Set-PCXFile "$ProjectRoot\.gitignore" @"
ops/logs/
ops/reports/
ops/artifacts/
.vscode/
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

# ---------------------------------------------------------------------
# Docs
# ---------------------------------------------------------------------
Set-PCXFile "$ProjectRoot\docs\GettingStarted.md" @"
Import-Module .\src\Modules\PCXLab.Core\dev\PCXLab.Core.psd1 -Force
Import-Module .\src\Modules\PCXLab.SCCM\dev\PCXLab.SCCM.psd1 -Force
"@

Set-PCXFile "$ProjectRoot\docs\NamingStandards.md" @"
PCX   = Core shared
PCXCM = SCCM specific
Verb-Noun naming
"@

Set-PCXFile "$ProjectRoot\docs\architecture\Overview.md" @"
src    = source code
config = settings
docs   = documentation
ops    = runtime outputs
tests  = validation
tools  = utilities
"@

Set-PCXFile "$ProjectRoot\docs\notes\DecisionLog.md" "# Decision Log"

Set-PCXFile "$ProjectRoot\docs\templates\AutomationTemplate.ps1" @'
Import-Module PCXLab.Core
Import-Module PCXLab.SCCM
Connect-PCXCMSite
Write-PCXLog -Message "Started"
'@

Set-PCXFile "$ProjectRoot\docs\templates\RunbookTemplate.ps1" 'Write-Host "Runbook Started"'

# ---------------------------------------------------------------------
# Ops
# ---------------------------------------------------------------------
Set-PCXFile "$ProjectRoot\ops\scripts\BuildRelease.ps1" 'Write-Host "Build release"'
Set-PCXFile "$ProjectRoot\ops\scripts\TestAll.ps1" 'Write-Host "Run tests"'
Set-PCXFile "$ProjectRoot\ops\scripts\CleanWorkspace.ps1" 'Write-Host "Clean workspace"'

Set-PCXFile "$ProjectRoot\ops\logs\README.md" "Store logs here."
Set-PCXFile "$ProjectRoot\ops\reports\README.md" "Store reports here."
Set-PCXFile "$ProjectRoot\ops\artifacts\README.md" "Store artifacts here."

# ---------------------------------------------------------------------
# Tools
# ---------------------------------------------------------------------
Set-PCXFile "$ProjectRoot\tools\README.md" @"
bootstrap = generators
signing   = signing tools
packaging = package helpers
helpers   = misc utilities
"@

# ---------------------------------------------------------------------
# Tests
# ---------------------------------------------------------------------
Set-PCXFile "$ProjectRoot\tests\README.md" "Use Pester tests here."

# ---------------------------------------------------------------------
# GitHub
# ---------------------------------------------------------------------
Set-PCXFile "$ProjectRoot\.github\workflows\README.md" "CI/CD YAML files go here."

Set-PCXFile "$ProjectRoot\.github\PULL_REQUEST_TEMPLATE.md" @"
## Summary
Describe changes.

## Validation
How tested?
"@

Set-PCXFile "$ProjectRoot\.github\ISSUE_TEMPLATE\bug_report.md" "Describe the defect."
Set-PCXFile "$ProjectRoot\.github\ISSUE_TEMPLATE\feature_request.md" "Describe the request."
Set-PCXFile "$ProjectRoot\.github\CODEOWNERS" "* @$Author"

# ---------------------------------------------------------------------
# Finish
# ---------------------------------------------------------------------
Write-Host ""
Write-Host "=========================================" -ForegroundColor Green
Write-Host "PCXCMAutomation V5.0 Ready" -ForegroundColor Green
Write-Host "Path: $ProjectRoot" -ForegroundColor Yellow
Write-Host "=========================================" -ForegroundColor Green