function Create-PCXCMPackage {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Path,
        [string]$Language = "EN-US",
        [string]$DPGroup = "All Mangalore Dps",
        [string]$LimitingCollectionName = "ALL Systems"
    )

    begin {
        Write-PCXOperationStart
    }

    process {
        $OriginalLocation = Get-Location
        try {

            $files = Test-PCXPackagePath $Path
            $FileMap = @{}
            foreach ($file in $files) {
                $FileMap[$file.Name.ToLower()] = $file
            }

            $installer = Get-PCXInstaller $files

            $meta = Get-PCXMetadataFromPath $Path
            $PackageName = "PKG $($meta.Name)"

            $programs = Get-PCXProgramNames -PackageName $PackageName
            $Collections = Get-PCXCollectionNames -PackageName $PackageName

            Write-PCXLog "Package: $PackageName"
            Write-PCXLog "Installer: $($installer.Name)"

            Ensure-PCXCMConnection

            $platforms = Get-CMSupportedPlatform -Fast | Where-Object { $_.DisplayText -like "*Windows 11*" }

            $null = New-PCXCMPackage -PackageName $PackageName -Company $meta.Company -Version $meta.Version -Language $Language -Path $Path

            $InstallCommand = Get-PCXCommandLineForPackage -Type "Install" -Installer $installer -FileMap $FileMap
            $UninstallCommand = Get-PCXCommandLineForPackage -Type "Uninstall" -Installer $installer -FileMap $FileMap
            $OSDCommand = Get-PCXCommandLineForPackage -Type "OSD" -Installer $installer -FileMap $FileMap

            Add-PCXProgram -PackageName $PackageName -Type "Install" -CommandLine $InstallCommand -Platforms $platforms
            Add-PCXProgram -PackageName $PackageName -Type "Available" -CommandLine $InstallCommand -Platforms $platforms
            Add-PCXProgram -PackageName $PackageName -Type "Uninstall" -CommandLine $UninstallCommand -Platforms $platforms

            if (Test-PCXHasUpgrade -FileMap $FileMap) {

                $UpgradeCommand = Get-PCXCommandLineForPackage -Type "Upgrade" -Installer $installer -FileMap $FileMap

                if ($UpgradeCommand) {
                    Add-PCXProgram -PackageName $PackageName -Type "Upgrade" -CommandLine $UpgradeCommand -Platforms $platforms
                }
            }

            Add-PCXProgram -PackageName $PackageName -Type "OSD" -CommandLine $OSDCommand -Platforms $platforms

            $null = Start-PCXCMContentDistribution -PackageName $PackageName -DistributionPointGroupName $DPGroup

            New-PCXCollections -Collections $Collections -LimitingCollectionName $LimitingCollectionName
            $DeadlineTime = (Get-Date -Hour 10 -Minute 0 -Second 0).AddDays(7)
            New-PCXCMPackageDeployments -PackageName $PackageName -Programs $programs -Collections $Collections -DeadlineTime $DeadlineTime

            Set-PCXCollectionRules -Collections $Collections
 
            $null = Move-PCXCMCollectionsToFolder -Collections $Collections -Meta $meta -ObjectName $PackageName
            $null = Move-PCXCMPackageToFolder -Meta $meta

            Write-PCXLog "SUCCESS: $PackageName"
        }
        catch {
            Write-PCXLog -Message $_.Exception.ToString() -Level ERROR 
            throw
        }
        finally {

            try {
                Set-Location $OriginalLocation
            }
            catch {
            }
        }
    }
    end {
        Write-PCXOperationEnd
    }
}

#Create-PCXCMPackage -Path "\\192.168.25.214\Package_Source\Applications\Igor Pavlov\7zip\7zip 26.0.2"

