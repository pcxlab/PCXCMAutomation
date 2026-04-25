# New-PCXModule.ps1
# V2.1 - PCXLab SCCM Project Scaffold Generator
# Creates:
#   PCXCMAutomation\
#     Modules\
#       PCXLab.Core\
#         dev\      (ModuleVersion 0.0.0 / wildcard exports)
#         0.1.0\    (ModuleVersion 0.1.0 / explicit exports)
#       PCXLab.SCCM\
#         dev\      (ModuleVersion 0.0.0 / wildcard exports)
#         0.1.0\    (ModuleVersion 0.1.0 / explicit exports)

[CmdletBinding()]
param(
    [string]$ProjectName = "PCXCMAutomation",

    # If not provided, uses the folder where this script exists
    [string]$BasePath = $PSScriptRoot,

    [string]$Author = "PCXLab"
)

# ------------------------------------------------------------
# Versions
# ------------------------------------------------------------
$DevVersion     = "0.0.0"
$ReleaseVersion = "0.1.0"

# ------------------------------------------------------------
# Paths
# ------------------------------------------------------------
$ProjectRoot = Join-Path $BasePath $ProjectName
$ModulesRoot = Join-Path $ProjectRoot "Modules"

$ModuleNames = @(
    "PCXLab.Core",
    "PCXLab.SCCM"
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

function New-PCXModuleFolders {
    param([string]$Root)

    @(
        "Public",
        "Private",
        "Classes",
        "Config",
        "Tests",
        "Docs"
    ) | ForEach-Object {
        New-PCXFolder (Join-Path $Root $_)
    }
}

function New-PCXLoader {
    param([string]$Path)

$Content = @'
# Auto load Private
Get-ChildItem -Path "$PSScriptRoot\Private\*.ps1" -ErrorAction SilentlyContinue |
Sort-Object Name |
ForEach-Object { . $_.FullName }

# Auto load Classes
Get-ChildItem -Path "$PSScriptRoot\Classes\*.ps1" -ErrorAction SilentlyContinue |
Sort-Object Name |
ForEach-Object { . $_.FullName }

# Auto load Public
Get-ChildItem -Path "$PSScriptRoot\Public\*.ps1" -ErrorAction SilentlyContinue |
Sort-Object Name |
ForEach-Object { . $_.FullName }
'@

    Set-PCXFile -Path $Path -Content $Content
}

function New-PCXManifest {
    param(
        [string]$Path,
        [string]$RootModule,
        [string]$Version,
        [string]$Description,
        [object]$FunctionsToExport
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

# ------------------------------------------------------------
# Root Project Structure
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
# Create Modules
# ------------------------------------------------------------
foreach ($ModuleName in $ModuleNames) {

    $ModuleRoot  = Join-Path $ModulesRoot $ModuleName
    $DevRoot     = Join-Path $ModuleRoot "dev"
    $ReleaseRoot = Join-Path $ModuleRoot $ReleaseVersion

    New-PCXModuleFolders $DevRoot
    New-PCXModuleFolders $ReleaseRoot

    $Psm1Name = "$ModuleName.psm1"
    $Psd1Name = "$ModuleName.psd1"

    # Loaders
    New-PCXLoader (Join-Path $DevRoot $Psm1Name)
    New-PCXLoader (Join-Path $ReleaseRoot $Psm1Name)

    # --------------------------------------------------------
    # CORE MODULE
    # --------------------------------------------------------
    if ($ModuleName -eq "PCXLab.Core") {

        $CoreFunctions = @(
            "Write-PCXLog",
            "Start-PCXLogSession",
            "Test-PCXEnvironment"
        )

        # DEV
        New-PCXManifest `
            -Path (Join-Path $DevRoot $Psd1Name) `
            -RootModule $Psm1Name `
            -Version $DevVersion `
            -Description "PCXLab Core Dev Module" `
            -FunctionsToExport "*"

        # RELEASE
        New-PCXManifest `
            -Path (Join-Path $ReleaseRoot $Psd1Name) `
            -RootModule $Psm1Name `
            -Version $ReleaseVersion `
            -Description "PCXLab Core Release Module" `
            -FunctionsToExport $CoreFunctions

        foreach ($Root in @($DevRoot,$ReleaseRoot)) {

            Set-PCXFile (Join-Path $Root "Public\Write-PCXLog.ps1") @'
function Write-PCXLog {
    [CmdletBinding()]
    param([string]$Message)

    $Time = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "[$Time] $Message"
}
'@

            Set-PCXFile (Join-Path $Root "Public\Start-PCXLogSession.ps1") @'
function Start-PCXLogSession {
    [CmdletBinding()]
    param()

    Write-Host "Log session started."
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
    }

    # --------------------------------------------------------
    # SCCM MODULE
    # --------------------------------------------------------
    if ($ModuleName -eq "PCXLab.SCCM") {

        $SCCMFunctions = @(
            "Connect-PCXCMSite",
            "Get-PCXCMDevice",
            "Get-PCXCMCollection",
            "New-PCXCMCollection"
        )

        # DEV
        New-PCXManifest `
            -Path (Join-Path $DevRoot $Psd1Name) `
            -RootModule $Psm1Name `
            -Version $DevVersion `
            -Description "PCXLab SCCM Dev Module" `
            -FunctionsToExport "*"

        # RELEASE
        New-PCXManifest `
            -Path (Join-Path $ReleaseRoot $Psd1Name) `
            -RootModule $Psm1Name `
            -Version $ReleaseVersion `
            -Description "PCXLab SCCM Release Module" `
            -FunctionsToExport $SCCMFunctions

        foreach ($Root in @($DevRoot,$ReleaseRoot)) {

            Set-PCXFile (Join-Path $Root "Public\Connect-PCXCMSite.ps1") @'
function Connect-PCXCMSite {
    [CmdletBinding()]
    param(
        [string]$SiteServer = "SCCM01"
    )

    Write-Host "Connected to site server: $SiteServer"
}
'@

            Set-PCXFile (Join-Path $Root "Public\Get-PCXCMDevice.ps1") @'
function Get-PCXCMDevice {
    [CmdletBinding()]
    param(
        [string]$Name
    )

    Write-Host "Searching device: $Name"
}
'@

            Set-PCXFile (Join-Path $Root "Public\Get-PCXCMCollection.ps1") @'
function Get-PCXCMCollection {
    [CmdletBinding()]
    param(
        [string]$Name
    )

    Write-Host "Searching collection: $Name"
}
'@

            Set-PCXFile (Join-Path $Root "Public\New-PCXCMCollection.ps1") @'
function New-PCXCMCollection {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [string]$Name
    )

    if ($PSCmdlet.ShouldProcess($Name,"Create Collection")) {
        Write-Host "Created collection: $Name"
    }
}
'@

            Set-PCXFile (Join-Path $Root "Private\Connect-CMSite.ps1") @'
function Connect-CMSite {
    param()
}
'@

            Set-PCXFile (Join-Path $Root "Config\Settings.json") @'
{
  "SiteServer": "SCCM01",
  "SiteCode": "P01"
}
'@
        }
    }
}

# ------------------------------------------------------------
# Root Files
# ------------------------------------------------------------
Set-PCXFile (Join-Path $ProjectRoot "README.md") @"
# $ProjectName

PowerShell automation project for SCCM.

## Modules

- PCXLab.Core
- PCXLab.SCCM
"@

Set-PCXFile (Join-Path $ProjectRoot "CHANGELOG.md") @"
# Changelog

## [$ReleaseVersion]
- Initial scaffold created
"@

Set-PCXFile (Join-Path $ProjectRoot "docs\GettingStarted.md") @'
# Getting Started

# DEV
Import-Module .\Modules\PCXLab.SCCM\dev\PCXLab.SCCM.psd1 -Force

# RELEASE
Import-Module .\Modules\PCXLab.SCCM\0.1.0\PCXLab.SCCM.psd1 -Force
'@

# ------------------------------------------------------------
# Output
# ------------------------------------------------------------
Write-Host ""
Write-Host "======================================" -ForegroundColor Green
Write-Host "PCXLab SCCM Project Created" -ForegroundColor Green
Write-Host "Path: $ProjectRoot" -ForegroundColor Yellow
Write-Host "BasePath: $BasePath" -ForegroundColor Yellow
Write-Host "Dev Version: $DevVersion" -ForegroundColor Yellow
Write-Host "Release Version: $ReleaseVersion" -ForegroundColor Yellow
Write-Host "======================================" -ForegroundColor Green

<#
USAGE

# Run from same folder as script
.\New-PCXModule.ps1

# Custom path
.\New-PCXModule.ps1 -BasePath D:\Projects

# DEV import
Import-Module .\Modules\PCXLab.SCCM\dev\PCXLab.SCCM.psd1 -Force

# RELEASE import
Import-Module .\Modules\PCXLab.SCCM\0.1.0\PCXLab.SCCM.psd1 -Force
#>