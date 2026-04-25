# New-PCXModule.ps1
# V2.3 Stable Checked Version
# Creates:
#   PCXCMAutomation\
#     Modules\
#       PCXLab.Core\
#         dev\
#         0.1.0\
#       PCXLab.SCCM\
#         dev\
#         0.1.0\

[CmdletBinding()]
param(
    [string]$ProjectName = "PCXCMAutomation",
    [string]$BasePath,
    [string]$Author = "PCXLab"
)

# ------------------------------------------------------------
# Safe BasePath
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
$DevVersion     = "0.0.0"
$ReleaseVersion = "0.1.0"

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

    $Parent = Split-Path $Path -Parent
    New-PCXFolder $Parent
    Set-Content -Path $Path -Value $Content -Encoding UTF8
}

function New-PCXModuleFolders {
    param([string]$Root)

    $Folders = @(
        "Public",
        "Private",
        "Classes",
        "Config",
        "Tests",
        "Docs"
    )

    foreach ($Folder in $Folders) {
        New-PCXFolder (Join-Path $Root $Folder)
    }
}

function New-PCXLoader {
    param([string]$Path)

$Loader = @'
# Auto load Private
Get-ChildItem "$PSScriptRoot\Private\*.ps1" -ErrorAction SilentlyContinue |
Sort-Object Name |
ForEach-Object { . $_.FullName }

# Auto load Classes
Get-ChildItem "$PSScriptRoot\Classes\*.ps1" -ErrorAction SilentlyContinue |
Sort-Object Name |
ForEach-Object { . $_.FullName }

# Auto load Public
Get-ChildItem "$PSScriptRoot\Public\*.ps1" -ErrorAction SilentlyContinue |
Sort-Object Name |
ForEach-Object { . $_.FullName }
'@

    Set-PCXFile -Path $Path -Content $Loader
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
# Root Structure
# ------------------------------------------------------------
Write-Host "Creating project structure..." -ForegroundColor Cyan

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
# Module Creation Function
# ------------------------------------------------------------
function New-PCXModuleScaffold {
    param(
        [string]$ModuleName,
        [string[]]$ReleaseExports,
        [string]$Description
    )

    $ModuleRoot = Join-Path $ModulesRoot $ModuleName
    $DevRoot    = Join-Path $ModuleRoot "dev"
    $RelRoot    = Join-Path $ModuleRoot $ReleaseVersion

    New-PCXModuleFolders $DevRoot
    New-PCXModuleFolders $RelRoot

    $Psm1 = "$ModuleName.psm1"
    $Psd1 = "$ModuleName.psd1"

    New-PCXLoader (Join-Path $DevRoot $Psm1)
    New-PCXLoader (Join-Path $RelRoot $Psm1)

    # DEV = wildcard exports
    New-PCXManifest `
        -Path (Join-Path $DevRoot $Psd1) `
        -RootModule $Psm1 `
        -Version $DevVersion `
        -Description "$Description Dev" `
        -FunctionsToExport "*"

    # RELEASE = fixed exports
    New-PCXManifest `
        -Path (Join-Path $RelRoot $Psd1) `
        -RootModule $Psm1 `
        -Version $ReleaseVersion `
        -Description "$Description Release" `
        -FunctionsToExport $ReleaseExports

    return @{
        DevRoot = $DevRoot
        RelRoot = $RelRoot
    }
}

# ------------------------------------------------------------
# CORE MODULE
# ------------------------------------------------------------
$Core = New-PCXModuleScaffold `
    -ModuleName "PCXLab.Core" `
    -Description "PCXLab Core Module" `
    -ReleaseExports @(
        "Start-PCXLogSession",
        "Write-PCXLog",
        "Test-PCXEnvironment"
    )

foreach ($Root in @($Core.DevRoot,$Core.RelRoot)) {

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
# SCCM MODULE
# ------------------------------------------------------------
$SCCM = New-PCXModuleScaffold `
    -ModuleName "PCXLab.SCCM" `
    -Description "PCXLab SCCM Module" `
    -ReleaseExports @(
        "Connect-PCXCMSite",
        "Get-PCXCMSiteCode",
        "Get-PCXCMProviderMachineName",
        "Get-PCXCMDevice",
        "Get-PCXCMCollection",
        "New-PCXCMCollection"
    )

foreach ($Root in @($SCCM.DevRoot,$SCCM.RelRoot)) {

Set-PCXFile (Join-Path $Root "Public\Get-PCXCMSiteCode.ps1") @'
function Get-PCXCMSiteCode {
    [CmdletBinding()]
    param()

    try {
        $siteObj = Get-WmiObject -Namespace "Root\SMS" -Class SMS_ProviderLocation -ComputerName "."
        if ($siteObj -is [array]) {
            return $siteObj[0].SiteCode
        }
        else {
            return $siteObj.SiteCode
        }
    }
    catch {
        throw "Error retrieving SCCM site code: $_"
    }
}
'@

Set-PCXFile (Join-Path $Root "Public\Get-PCXCMProviderMachineName.ps1") @'
function Get-PCXCMProviderMachineName {
    [CmdletBinding()]
    param()

    try {
        $obj = Get-WmiObject -Namespace "Root\SMS" -Class SMS_ProviderLocation -ErrorAction Stop |
               Where-Object { $_.ProviderForLocalSite -eq $true }

        if ($null -eq $obj) {
            return $null
        }

        return $obj.Machine
    }
    catch {
        return $null
    }
}
'@

Set-PCXFile (Join-Path $Root "Public\Connect-PCXCMSite.ps1") @'
function Connect-PCXCMSite {

    param(
        [string]$SiteCode = $(Get-PCXCMSiteCode),
        [string]$ProviderMachineName = $(Get-PCXCMProviderMachineName)
    )

    if (-not (Get-Module ConfigurationManager)) {
        $cmPath = Join-Path $env:SMS_ADMIN_UI_PATH "..\ConfigurationManager.psd1"
        Import-Module $cmPath -ErrorAction Stop
    }

    if (-not (Get-PSDrive -Name $SiteCode -PSProvider CMSite -ErrorAction SilentlyContinue)) {
        New-PSDrive -Name $SiteCode -PSProvider CMSite -Root $ProviderMachineName | Out-Null
    }

    Set-Location "$SiteCode`:\"
}
'@

Set-PCXFile (Join-Path $Root "Public\Get-PCXCMDevice.ps1") @'
function Get-PCXCMDevice {
    [CmdletBinding()]
    param([string]$Name)

    Write-Host "Searching device: $Name"
}
'@

Set-PCXFile (Join-Path $Root "Public\Get-PCXCMCollection.ps1") @'
function Get-PCXCMCollection {
    [CmdletBinding()]
    param([string]$Name)

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

Set-PCXFile (Join-Path $Root "Config\Settings.json") @'
{
  "SiteServer": "SCCM01",
  "SiteCode": "P01"
}
'@

}

# ------------------------------------------------------------
# Root Files
# ------------------------------------------------------------
Set-PCXFile (Join-Path $ProjectRoot "README.md") @"
# $ProjectName

PowerShell SCCM automation project.

## Modules
- PCXLab.Core
- PCXLab.SCCM
"@

Set-PCXFile (Join-Path $ProjectRoot "CHANGELOG.md") @"
# Changelog

## [$ReleaseVersion]
- Initial scaffold created
"@

# ------------------------------------------------------------
# Finish
# ------------------------------------------------------------
Write-Host ""
Write-Host "======================================" -ForegroundColor Green
Write-Host "Project Created Successfully" -ForegroundColor Green
Write-Host "Path: $ProjectRoot" -ForegroundColor Yellow
Write-Host "======================================" -ForegroundColor Green