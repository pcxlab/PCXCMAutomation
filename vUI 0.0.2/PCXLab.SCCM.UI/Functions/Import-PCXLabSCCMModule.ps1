function Import-PCXLabSCCMModule {

    [CmdletBinding()]
    param()

    $ProjectRoot = Split-Path (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent) -Parent

    $ModuleRoot = Join-Path $ProjectRoot "src\Modules\PCXLab.SCCM"

    if (-not (Test-Path $ModuleRoot)) {
        throw "PCXLab.SCCM module folder not found."
    }

    $VersionFolders = Get-ChildItem $ModuleRoot -Directory | Where-Object {
        $_.Name -match '^\d+\.\d+\.\d+$'
    }

    $LatestVersionFolder = $VersionFolders |
        Sort-Object { [version]$_.Name } -Descending |
        Select-Object -First 1

    if (-not $LatestVersionFolder) {
        throw "No PCXLab.SCCM module version found."
    }

    $ManifestPath = Join-Path $LatestVersionFolder.FullName "PCXLab.SCCM.psd1"

    if (-not (Test-Path $ManifestPath)) {
        throw "Module manifest not found: $ManifestPath"
    }

    Get-Module PCXLab.SCCM |
        Remove-Module -Force -ErrorAction SilentlyContinue

    Import-Module $ManifestPath -Force -ErrorAction Stop

    $LoadedModule = Get-Module PCXLab.SCCM

    if (-not $LoadedModule) {
        throw "PCXLab.SCCM module failed to load."
    }

    return $LoadedModule
}