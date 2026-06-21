function Import-PCXLabSCCMModule {
    [CmdletBinding()]
    param()

    # If already loaded, just return
    $ExistingModule = Get-Module PCXLab.SCCM
    if ($ExistingModule) {
        return $ExistingModule
    }

    $ModuleRoot = Join-Path $PSScriptRoot "..\..\..\..\src\Modules\PCXLab.SCCM"
    if (-not (Test-Path $ModuleRoot)) {
        throw "PCXLab.SCCM module folder not found at: $ModuleRoot"
    }

    # Faster version discovery
    $LatestVersionFolder = Get-ChildItem $ModuleRoot -Directory | 
        Where-Object { $_.Name -match '^\d+\.\d+\.\d+$' } |
        Sort-Object { [version]$_.Name } -Descending |
        Select-Object -First 1

    if (-not $LatestVersionFolder) {
        throw "No PCXLab.SCCM module version found in: $ModuleRoot"
    }

    $ManifestPath = Join-Path $LatestVersionFolder.FullName "PCXLab.SCCM.psd1"
    if (-not (Test-Path $ManifestPath)) {
        throw "Module manifest not found: $ManifestPath"
    }

    Import-Module $ManifestPath -ErrorAction Stop
    
    return Get-Module PCXLab.SCCM
}