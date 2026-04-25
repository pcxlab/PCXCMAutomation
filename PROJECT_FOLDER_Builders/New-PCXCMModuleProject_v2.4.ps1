# New-PCXModule.ps1
# V2.4
# Creates full PCXCMAutomation scaffold with:
#   Modules\PCXLab.Core\dev,0.0.0,0.1.0
#   Modules\PCXLab.SCCM\dev,0.0.0,0.1.0
# Includes SCCM domain subfolders

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
$ModulesRoot = Join-Path $ProjectRoot "Modules"

# ------------------------------------------------------------
# Helpers
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

    $parent = Split-Path $Path -Parent
    New-PCXFolder $parent
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

$loader = @'
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

    Set-PCXFile -Path $Path -Content $loader
}

# ------------------------------------------------------------
# Root Project
# ------------------------------------------------------------
Write-Host "Creating project..." -ForegroundColor Cyan

@(
    $ProjectRoot,
    $ModulesRoot,
    (Join-Path $ProjectRoot "docs"),
    (Join-Path $ProjectRoot "notes"),
    (Join-Path $ProjectRoot "tools")
) | ForEach-Object {
    New-PCXFolder $_
}

# ------------------------------------------------------------
# Core Structure
# ------------------------------------------------------------
foreach ($VersionFolder in $Versions) {

    $VersionNumber = if ($VersionFolder -eq "dev") { "0.0.0" } else { $VersionFolder }

    $Root = Join-Path $ModulesRoot "PCXLab.Core\$VersionFolder"

    @(
        "Public",
        "Private",
        "Classes",
        "Config",
        "Docs",
        "Tests"
    ) | ForEach-Object {
        New-PCXFolder (Join-Path $Root $_)
    }

    New-PCXLoader (Join-Path $Root "PCXLab.Core.psm1")

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

    New-PCXManifest `
        -Path (Join-Path $Root "PCXLab.Core.psd1") `
        -RootModule "PCXLab.Core.psm1" `
        -Version $VersionNumber `
        -FunctionsToExport $Exports `
        -Description "PCXLab Core Module"

    Set-PCXFile (Join-Path $Root "Public\Start-PCXLogSession.ps1") @'
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

    Set-PCXFile (Join-Path $Root "Public\Write-PCXLog.ps1") @'
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

    Set-PCXFile (Join-Path $Root "Public\Test-PCXEnvironment.ps1") @'
function Test-PCXEnvironment {
    [CmdletBinding()]
    param()

    return $true
}
'@
}

# ------------------------------------------------------------
# SCCM Structure
# ------------------------------------------------------------
$PublicDomains = @(
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

foreach ($VersionFolder in $Versions) {

    $VersionNumber = if ($VersionFolder -eq "dev") { "0.0.0" } else { $VersionFolder }

    $Root = Join-Path $ModulesRoot "PCXLab.SCCM\$VersionFolder"

    New-PCXFolder $Root
    New-PCXFolder (Join-Path $Root "Private")
    New-PCXFolder (Join-Path $Root "Classes")
    New-PCXFolder (Join-Path $Root "Config")
    New-PCXFolder (Join-Path $Root "Docs")
    New-PCXFolder (Join-Path $Root "Tests")

    foreach ($Domain in $PublicDomains) {
        New-PCXFolder (Join-Path $Root "Public\$Domain")
    }

    New-PCXLoader (Join-Path $Root "PCXLab.SCCM.psm1")

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

    New-PCXManifest `
        -Path (Join-Path $Root "PCXLab.SCCM.psd1") `
        -RootModule "PCXLab.SCCM.psm1" `
        -Version $VersionNumber `
        -FunctionsToExport $Exports `
        -Description "PCXLab SCCM Module"

    # Connection
    Set-PCXFile (Join-Path $Root "Public\Connection\Connect-PCXCMSite.ps1") @'
function Connect-PCXCMSite {
    Write-Host "Connected to SCCM Site"
}
'@

    Set-PCXFile (Join-Path $Root "Public\Connection\Get-PCXCMSiteCode.ps1") @'
function Get-PCXCMSiteCode {
    return "P01"
}
'@

    Set-PCXFile (Join-Path $Root "Public\Connection\Get-PCXCMProviderMachineName.ps1") @'
function Get-PCXCMProviderMachineName {
    return $env:COMPUTERNAME
}
'@

    # Collections
    Set-PCXFile (Join-Path $Root "Public\Collections\Get-PCXCMCollection.ps1") @'
function Get-PCXCMCollection {
    param([string]$Name)
    Write-Host "Collection: $Name"
}
'@

    Set-PCXFile (Join-Path $Root "Public\Collections\New-PCXCMCollection.ps1") @'
function New-PCXCMCollection {
    param([string]$Name)
    Write-Host "Created Collection: $Name"
}
'@

    # Devices
    Set-PCXFile (Join-Path $Root "Public\Devices\Get-PCXCMDevice.ps1") @'
function Get-PCXCMDevice {
    param([string]$Name)
    Write-Host "Device: $Name"
}
'@

    Set-PCXFile (Join-Path $Root "Config\Settings.json") @'
{
  "SiteCode": "P01",
  "ProviderMachine": "SCCM01"
}
'@
}

# ------------------------------------------------------------
# Root Files
# ------------------------------------------------------------
Set-PCXFile (Join-Path $ProjectRoot "README.md") @"
# $ProjectName

PowerShell SCCM Automation Framework

## Modules
- PCXLab.Core
- PCXLab.SCCM
"@

Set-PCXFile (Join-Path $ProjectRoot "CHANGELOG.md") @"
# Changelog

## [0.1.0]
- Initial framework created
"@

# ------------------------------------------------------------
# Finish
# ------------------------------------------------------------
Write-Host ""
Write-Host "======================================" -ForegroundColor Green
Write-Host "Project Created Successfully" -ForegroundColor Green
Write-Host "Path: $ProjectRoot" -ForegroundColor Yellow
Write-Host "======================================" -ForegroundColor Green