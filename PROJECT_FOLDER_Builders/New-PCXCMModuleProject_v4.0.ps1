# New-PCXCMAutomation.ps1
# V4 Final Professional Version
# Clean architecture + versioned modules + automations + runbooks
# Nothing lost from previous versions

[CmdletBinding()]
param(
    [string]$ProjectName = "PCXCMAutomation",
    [string]$BasePath,
    [string]$Author = "PCXLab"
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
# Load Private
Get-ChildItem "$PSScriptRoot\Private\*.ps1" -Recurse -ErrorAction SilentlyContinue |
Sort-Object FullName |
ForEach-Object { . $_.FullName }

# Load Classes
Get-ChildItem "$PSScriptRoot\Classes\*.ps1" -Recurse -ErrorAction SilentlyContinue |
Sort-Object FullName |
ForEach-Object { . $_.FullName }

# Load Public
Get-ChildItem "$PSScriptRoot\Public\*.ps1" -Recurse -ErrorAction SilentlyContinue |
Sort-Object FullName |
ForEach-Object { . $_.FullName }
'@

    Set-PCXFile -Path $Path -Content $Loader
}

# ------------------------------------------------------------
# Root Structure
# ------------------------------------------------------------
$Folders = @(
    $ProjectRoot,

    "$ProjectRoot\src",
    "$ProjectRoot\config",
    "$ProjectRoot\docs",
    "$ProjectRoot\ops",
    "$ProjectRoot\tests",
    "$ProjectRoot\.github\workflows",

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
    "$ProjectRoot\tests\Regression"
)

Write-Host "Creating structure..." -ForegroundColor Cyan

foreach ($Folder in $Folders) {
    New-PCXFolder $Folder
}

# ------------------------------------------------------------
# Module Domains
# ------------------------------------------------------------
$SCCMDomains = @(
    "Connection",
    "Collections",
    "Devices",
    "Applications",
    "Packages",
    "Queries",
    "Folders",
    "SoftwareUpdates",
    "TaskSequences",
    "OSD",
    "Drivers",
    "Baselines",
    "Utilities"
)

# ------------------------------------------------------------
# Create Modules with Versions
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

        # ----------------------------------------------------
        # Exports
        # ----------------------------------------------------
        if ($Module -eq "PCXLab.Core") {

            $Exports = if ($VersionFolder -eq "dev") {
                "*"
            }
            else {
                @(
                    "Start-PCXLogSession",
                    "Write-PCXLog",
                    "Test-PCXEnvironment"
                )
            }
        }
        else {

            $Exports = if ($VersionFolder -eq "dev") {
                "*"
            }
            else {
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

        # ----------------------------------------------------
        # Core Files
        # ----------------------------------------------------
        if ($Module -eq "PCXLab.Core") {

Set-PCXFile (Join-Path $ModuleRoot "Public\Start-PCXLogSession.ps1") @'
function Start-PCXLogSession {
    param(
        [Parameter(Mandatory)]
        [string]$LogFolder
    )

    if (-not (Test-Path $LogFolder)) {
        New-Item -Path $LogFolder -ItemType Directory -Force | Out-Null
    }

    $timeStamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $global:PCXLabLogFile = Join-Path $LogFolder "Run_$timeStamp.log"

    New-Item -Path $global:PCXLabLogFile -ItemType File -Force | Out-Null

    Write-Host "Logging started: $global:PCXLabLogFile"
}
'@

Set-PCXFile (Join-Path $ModuleRoot "Public\Write-PCXLog.ps1") @'
function Write-PCXLog {
    param(
        [Parameter(Mandatory)]
        [string]$Message,

        [string]$Level = "INFO"
    )

    if (-not $global:PCXLabLogFile) {
        throw "Log session not initialized. Use Start-PCXLogSession first."
    }

    $time = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $line = "$time [$Level] $Message"

    Add-Content -Path $global:PCXLabLogFile -Value $line
    Write-Host $line
}
'@

Set-PCXFile (Join-Path $ModuleRoot "Public\Test-PCXEnvironment.ps1") @'
function Test-PCXEnvironment {
    [CmdletBinding()]
    param()

    return $true
}
'@
        }

        # ----------------------------------------------------
        # SCCM Files
        # ----------------------------------------------------
        if ($Module -eq "PCXLab.SCCM") {

Set-PCXFile (Join-Path $ModuleRoot "Public\Connection\Connect-PCXCMSite.ps1") @'
function Connect-PCXCMSite {
    Write-Host "Connected to SCCM Site"
}
'@

Set-PCXFile (Join-Path $ModuleRoot "Public\Connection\Get-PCXCMSiteCode.ps1") @'
function Get-PCXCMSiteCode {
    return "P01"
}
'@

Set-PCXFile (Join-Path $ModuleRoot "Public\Connection\Get-PCXCMProviderMachineName.ps1") @'
function Get-PCXCMProviderMachineName {
    return $env:COMPUTERNAME
}
'@

Set-PCXFile (Join-Path $ModuleRoot "Public\Collections\Get-PCXCMCollection.ps1") @'
function Get-PCXCMCollection {
    param([string]$Name)
    Write-Host "Collection: $Name"
}
'@

Set-PCXFile (Join-Path $ModuleRoot "Public\Collections\New-PCXCMCollection.ps1") @'
function New-PCXCMCollection {
    param([string]$Name)
    Write-Host "Created Collection: $Name"
}
'@

Set-PCXFile (Join-Path $ModuleRoot "Public\Devices\Get-PCXCMDevice.ps1") @'
function Get-PCXCMDevice {
    param([string]$Name)
    Write-Host "Device: $Name"
}
'@

Set-PCXFile (Join-Path $ModuleRoot "Config\Settings.json") @'
{
  "SiteCode": "P01",
  "ProviderMachine": "SCCM01"
}
'@
        }
    }
}

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
"@

Set-PCXFile "$ProjectRoot\CHANGELOG.md" @"
# Changelog

## [1.0.0]
- Final professional scaffold created
"@

Set-PCXFile "$ProjectRoot\LICENSE" "MIT License"

# ------------------------------------------------------------
# Config
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

Set-PCXFile "$ProjectRoot\config\environments\Prod.json" @'
{
  "SiteCode": "PR1",
  "ProviderMachine": "SCCMPROD01"
}
'@

# ------------------------------------------------------------
# Finish
# ------------------------------------------------------------
Write-Host ""
Write-Host "=========================================" -ForegroundColor Green
Write-Host "PCXCMAutomation V4 Ready" -ForegroundColor Green
Write-Host "Path: $ProjectRoot" -ForegroundColor Yellow
Write-Host "=========================================" -ForegroundColor Green