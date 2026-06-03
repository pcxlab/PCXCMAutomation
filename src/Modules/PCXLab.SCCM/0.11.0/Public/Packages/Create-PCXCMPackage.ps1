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
            $installer = Get-PCXInstaller $files

            $meta = Get-PCXMetadataFromPath $Path
            $PackageName = "PKG $($meta.Name)"

            $programs = Get-PCXProgramNames -PackageName $PackageName
            $Collections = Get-PCXCollectionNames -PackageName $PackageName

            Write-PCXLog "Package: $PackageName"
            Write-PCXLog "Installer: $($installer.Name)"

            #############TESTING ONLY
            Write-PCXLog "Current Location: $(Get-Location)"
            Ensure-PCXCMConnection
            Write-PCXLog "After Connect: $(Get-Location)"

            $platforms = Get-CMSupportedPlatform -Fast | Where-Object { $_.DisplayText -like "*Windows 11*" }

            #$null = New-CMPackage -Name $PackageName -Manufacturer $meta.Company -Version $meta.Version -Language $Language -Path $Path
            $null = New-PCXCMPackage -PackageName $PackageName -Company $meta.Company -Version $meta.Version -Language $Language -Path $Path

            Write-PCXLog "Package created"

            $InstallCommand = Get-PCXCommandLineForPackage -Path $Path -Type "Install" -Installer $installer
            $UninstallCommand = Get-PCXCommandLineForPackage -Path $Path -Type "Uninstall" -Installer $installer
            $OSDCommand = Get-PCXCommandLineForPackage -Path $Path -Type "OSD" -Installer $installer

            Add-PCXProgram -PackageName $PackageName -Type "Install" -CommandLine $InstallCommand -Platforms $platforms
            Add-PCXProgram -PackageName $PackageName -Type "Available" -CommandLine $InstallCommand -Platforms $platforms
            Add-PCXProgram -PackageName $PackageName -Type "Uninstall" -CommandLine $UninstallCommand -Platforms $platforms

            if (Test-PCXHasUpgrade $Path) {

                $UpgradeCommand = Get-PCXCommandLineForPackage -Path $Path -Type "Upgrade" -Installer $installer

                if ($UpgradeCommand) {
                    Add-PCXProgram -PackageName $PackageName -Type "Upgrade" -CommandLine $UpgradeCommand -Platforms $platforms
                }
            }

            Add-PCXProgram -PackageName $PackageName -Type "OSD" -CommandLine $OSDCommand -Platforms $platforms

            $null = Start-PCXCMContentDistribution -PackageName $PackageName -DistributionPointGroupName $DPGroup

            New-PCXCollections -Collections $Collections -LimitingCollectionName $LimitingCollectionName
            $DeadlineTime = (Get-Date -Hour 20 -Minute 0 -Second 0).AddDays(30)
            New-PCXDeployments -PackageName $PackageName -Programs $programs -Collections $Collections -DeadlineTime $DeadlineTime

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


