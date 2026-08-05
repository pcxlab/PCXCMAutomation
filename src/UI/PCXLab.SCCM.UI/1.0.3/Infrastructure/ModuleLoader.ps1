class ModuleLoader {
    static [object] ImportPCXLabSCCMModule([string]$versionPath) {
        $existingModule = Get-Module PCXLab.SCCM
        if ($existingModule) {
            return $existingModule
        }

        # Navigate relative to the version-specific directory to find src/Modules/PCXLab.SCCM
        $moduleRoot = Join-Path $versionPath "..\..\..\src\Modules\PCXLab.SCCM"
        if (-not (Test-Path $moduleRoot)) {
            throw "PCXLab.SCCM module folder not found at: $moduleRoot"
        }

        # Version discovery
        $latestVersionFolder = Get-ChildItem $moduleRoot -Directory | 
            Where-Object { $_.Name -match '^\d+\.\d+\.\d+$' } |
            Sort-Object { [version]$_.Name } -Descending |
            Select-Object -First 1

        if (-not $latestVersionFolder) {
            throw "No PCXLab.SCCM module version found in: $moduleRoot"
        }

        $manifestPath = Join-Path $latestVersionFolder.FullName "PCXLab.SCCM.psd1"
        if (-not (Test-Path $manifestPath)) {
            throw "Module manifest not found: $manifestPath"
        }

        Import-Module $manifestPath -ErrorAction Stop
        
        return Get-Module PCXLab.SCCM
    }

    static [void] InitializeUI([string]$versionPath) {
        $loadedModule = [ModuleLoader]::ImportPCXLabSCCMModule($versionPath)

        $requiredCommands = @("Create-PCXCMPackage", "Create-PCXCMApplication")
        foreach ($cmd in $requiredCommands) {
            if (-not (Get-Command $cmd -ErrorAction SilentlyContinue)) {
                throw "Required command '$cmd' not found in loaded module."
            }
        }

        [Logger]::Log("Loaded Module : $($loadedModule.Name) v$($loadedModule.Version)", "SUCCESS")
    }
}
