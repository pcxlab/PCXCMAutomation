class ModuleLoader {

    static [object] ImportPCXLabSCCMModule([string]$appPath) {

        #------------------------------------------------------------
        # Already loaded?
        #------------------------------------------------------------
        $existingModule = Get-Module -Name PCXLab.SCCM
        if ($existingModule) {
            return $existingModule
        }

        #------------------------------------------------------------
        # 1. Installed Module (Preferred)
        #------------------------------------------------------------
        $installedModule = Get-Module -ListAvailable -Name PCXLab.SCCM |
        Sort-Object Version -Descending |
        Select-Object -First 1

        if ($installedModule) {

            Import-Module PCXLab.SCCM -Force -ErrorAction Stop

            return Get-Module -Name PCXLab.SCCM
        }

        #------------------------------------------------------------
        # 2. Portable Deployment
        #
        # Example:
        # C:\Program Files\PCXLab
        # ├── Modules
        # │   └── PCXLab.SCCM
        # └── UI
        #     └── PCXLab.SCCM.UI
        #------------------------------------------------------------
        $portableModuleRoot = Join-Path $appPath "..\..\Modules\PCXLab.SCCM"

        if (Test-Path $portableModuleRoot) {

            $manifest = [ModuleLoader]::GetLatestManifest($portableModuleRoot)

            Import-Module $manifest -Force -ErrorAction Stop

            return Get-Module -Name PCXLab.SCCM
        }

        #------------------------------------------------------------
        # 3. Development Mode
        #------------------------------------------------------------
        $developmentModuleRoot = Join-Path $appPath "..\..\..\src\Modules\PCXLab.SCCM"

        if (Test-Path $developmentModuleRoot) {

            $manifest = [ModuleLoader]::GetLatestManifest($developmentModuleRoot)

            Import-Module $manifest -Force -ErrorAction Stop

            return Get-Module -Name PCXLab.SCCM
        }

        throw @"
Unable to locate the PCXLab.SCCM module.

The loader searched:

1. Installed module
2. Portable deployment
3. Development source

Expected locations:

Installed
---------
C:\Program Files\WindowsPowerShell\Modules\PCXLab.SCCM

Portable
--------
..\..\Modules\PCXLab.SCCM

Development
-----------
..\..\..\src\Modules\PCXLab.SCCM
"@
    }

    static [string] GetLatestManifest([string]$moduleRoot) {

        $latestVersionFolder = Get-ChildItem $moduleRoot -Directory |
        Where-Object {
            $_.Name -match '^\d+\.\d+\.\d+$'
        } |
        Sort-Object {
            [version]$_.Name
        } -Descending |
        Select-Object -First 1

        if (-not $latestVersionFolder) {
            throw "No module version folders found in '$moduleRoot'."
        }

        $manifestPath = Join-Path $latestVersionFolder.FullName "PCXLab.SCCM.psd1"

        if (-not (Test-Path $manifestPath)) {
            throw "Module manifest not found:`n$manifestPath"
        }

        return $manifestPath
    }

    static [void] InitializeUI([string]$appPath) {

        $loadedModule = [ModuleLoader]::ImportPCXLabSCCMModule($appPath)

        $requiredCommands = @(
            "Create-PCXCMPackage",
            "Create-PCXCMApplication"
        )

        foreach ($command in $requiredCommands) {

            if (-not (Get-Command $command -ErrorAction SilentlyContinue)) {
                throw "Required command '$command' not found in PCXLab.SCCM."
            }
        }

        [Logger]::Log(
            "Loaded Module : $($loadedModule.Name) v$($loadedModule.Version)",
            "SUCCESS"
        )
    }

}