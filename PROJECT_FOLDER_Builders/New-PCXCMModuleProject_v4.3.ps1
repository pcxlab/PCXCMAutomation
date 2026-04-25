# New-PCXCMAutomation.ps1
# V4.3 Final Long-Term Scaffold
# GitHub-ready + Tools added + Preserves all V4.2 capabilities

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
# Versions
# ------------------------------------------------------------
$Versions = @("dev","0.0.0","0.1.0")

# ------------------------------------------------------------
# Paths
# ------------------------------------------------------------
$ProjectRoot = Join-Path $BasePath $ProjectName
$SrcRoot     = Join-Path $ProjectRoot "src"
$ModulesRoot = Join-Path $SrcRoot "Modules"

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
Get-ChildItem "$PSScriptRoot\Private\*.ps1" -Recurse -ErrorAction SilentlyContinue |
Sort-Object FullName | ForEach-Object { . $_.FullName }

Get-ChildItem "$PSScriptRoot\Classes\*.ps1" -Recurse -ErrorAction SilentlyContinue |
Sort-Object FullName | ForEach-Object { . $_.FullName }

Get-ChildItem "$PSScriptRoot\Public\*.ps1" -Recurse -ErrorAction SilentlyContinue |
Sort-Object FullName | ForEach-Object { . $_.FullName }
'@

    Set-PCXFile -Path $Path -Content $Loader
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

Write-Host "Creating V4.3 scaffold..." -ForegroundColor Cyan
foreach ($Folder in $Folders) { New-PCXFolder $Folder }

# ------------------------------------------------------------
# SCCM Domains
# ------------------------------------------------------------
$SCCMDomains = @(
"Connection","Collections","Devices","Applications","Packages",
"Queries","Folders","SoftwareUpdates","TaskSequences",
"OSD","Drivers","Baselines","Utilities"
)

# ------------------------------------------------------------
# Modules with Versions
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
        } else {
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
        } else {
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
0.0.0 = baseline
0.1.0 = stable release
"@
    }
}

# ------------------------------------------------------------
# Sample Core Functions
# ------------------------------------------------------------
Set-PCXFile "$ModulesRoot\PCXLab.Core\dev\Public\Start-PCXLogSession.ps1" @'
function Start-PCXLogSession {
    param([string]$LogFolder)
    Write-Host "Logging started"
}
'@

Set-PCXFile "$ModulesRoot\PCXLab.Core\dev\Public\Write-PCXLog.ps1" @'
function Write-PCXLog {
    param([string]$Message)
    Write-Host $Message
}
'@

# ------------------------------------------------------------
# Sample SCCM Functions
# ------------------------------------------------------------
Set-PCXFile "$ModulesRoot\PCXLab.SCCM\dev\Public\Connection\Connect-PCXCMSite.ps1" @'
function Connect-PCXCMSite { Write-Host "Connected" }
'@

Set-PCXFile "$ModulesRoot\PCXLab.SCCM\dev\Public\Collections\New-PCXCMCollection.ps1" @'
function New-PCXCMCollection { param([string]$Name) }
'@

# ------------------------------------------------------------
# Root Files
# ------------------------------------------------------------
Set-PCXFile "$ProjectRoot\README.md" @"
# PCXCMAutomation

Professional PowerShell automation framework for SCCM / MECM.

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

## [4.3.0]
- GitHub-ready scaffold
- Tools area added
- Preserved module versioning
"@

Set-PCXFile "$ProjectRoot\LICENSE" "MIT License"

Set-PCXFile "$ProjectRoot\.gitignore" @"
# Logs
ops/logs/

# Reports
ops/reports/

# Artifacts
ops/artifacts/

# VS Code
.vscode/

# PowerShell temp
*.tmp
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

Import dev module:

Import-Module .\src\Modules\PCXLab.SCCM\dev\PCXLab.SCCM.psd1 -Force
"@

Set-PCXFile "$ProjectRoot\docs\NamingStandards.md" @"
PCX   = Core shared
PCXCM = SCCM
Verb-Noun format
"@

Set-PCXFile "$ProjectRoot\docs\notes\README.md" "Use for architecture notes and decisions."

# ------------------------------------------------------------
# Ops
# ------------------------------------------------------------
Set-PCXFile "$ProjectRoot\ops\scripts\README.md" "Project maintenance scripts only."
Set-PCXFile "$ProjectRoot\ops\scripts\BuildRelease.ps1" 'Write-Host "Build release"'
Set-PCXFile "$ProjectRoot\ops\scripts\TestAll.ps1" 'Write-Host "Run tests"'

Set-PCXFile "$ProjectRoot\ops\logs\README.md" "Runtime logs stored here."
Set-PCXFile "$ProjectRoot\ops\reports\README.md" "Generated reports stored here."
Set-PCXFile "$ProjectRoot\ops\artifacts\README.md" "Build artifacts stored here."

# ------------------------------------------------------------
# Tools
# ------------------------------------------------------------
Set-PCXFile "$ProjectRoot\tools\README.md" @"
Standalone helper utilities.

bootstrap = project generators
signing   = cert/signing helpers
packaging = zip/package helpers
helpers   = misc reusable utilities
"@

Set-PCXFile "$ProjectRoot\tools\bootstrap\README.md" "Project bootstrap scripts."
Set-PCXFile "$ProjectRoot\tools\signing\README.md" "Code signing tools."
Set-PCXFile "$ProjectRoot\tools\packaging\README.md" "Packaging helpers."
Set-PCXFile "$ProjectRoot\tools\helpers\README.md" "Misc helper tools."

# ------------------------------------------------------------
# Tests
# ------------------------------------------------------------
Set-PCXFile "$ProjectRoot\tests\README.md" "Use Pester tests here."

# ------------------------------------------------------------
# GitHub
# ------------------------------------------------------------
Set-PCXFile "$ProjectRoot\.github\workflows\README.md" "Place CI/CD YAML workflows here."

Set-PCXFile "$ProjectRoot\.github\PULL_REQUEST_TEMPLATE.md" @"
## Summary

Describe changes.

## Validation

How did you test?
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
about: Suggest an improvement
---

Describe the request.
"@

Set-PCXFile "$ProjectRoot\.github\CODEOWNERS" "* @$Author"

# ------------------------------------------------------------
# Finish
# ------------------------------------------------------------
Write-Host ""
Write-Host "=========================================" -ForegroundColor Green
Write-Host "PCXCMAutomation V4.3 Ready" -ForegroundColor Green
Write-Host "Path: $ProjectRoot" -ForegroundColor Yellow
Write-Host "=========================================" -ForegroundColor Green