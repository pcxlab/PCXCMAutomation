function Create-PCXCMPackage {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Path,

        [string]$Language = "EN-US",
        [string[]]$DistributionPointGroups, # Array Difined
        [string[]]$DistributionPoints, # Array Difined
        [string]$LimitingCollectionName = (Get-PCXCMDefaultLimitingCollection),
        [string]$ReferenceNumber,
        [string]$ReviewerName,
        [string]$Comments
    )

    begin {
        Write-PCXOperationStart
    }

    process {
        $OriginalLocation = Get-Location
        try {

            $Files = Test-PCXPackagePath $Path
            $FileMap = @{}
            foreach ($File in $Files) {
                $FileMap[$File.Name.ToLower()] = $File
            }

            $Installer = Get-PCXCMPackageInstaller $Files

            $Meta = Get-PCXMetadataFromPath $Path
            $PackageName = "PKG $($Meta.Name)"

            $Programs = New-PCXCMPackageProgramNames -PackageName $PackageName
            $Collections = New-PCXCMDeploymentCollectionNames -ObjectName $PackageName

            Write-PCXLog "Package: $PackageName"
            Write-PCXLog "Installer: $($Installer.Name)"

            Ensure-PCXCMConnection

            $Platforms = Get-CMSupportedPlatform -Fast | Where-Object { $_.DisplayText -like "*Windows 11*" }

            #$Package = New-PCXCMPackage -PackageName $PackageName -Company $meta.Company -Version $meta.Version -Language $Language -Path $Path
            $null = New-PCXCMPackage -PackageName $PackageName -Company $meta.Company -Version $meta.Version -Language $Language -Path $Path

            $null = Start-PCXCMContentDistribution `
                -PackageName $PackageName `
                -DistributionPointGroups $DistributionPointGroups `
                -DistributionPoints $DistributionPoints

            $InstallCommand = Get-PCXCMCommandLineForPackage -Type "Install" -Installer $Installer -FileMap $FileMap
            $UninstallCommand = Get-PCXCMCommandLineForPackage -Type "Uninstall" -Installer $Installer -FileMap $FileMap
            $OSDCommand = Get-PCXCMCommandLineForPackage -Type "OSD" -Installer $Installer -FileMap $FileMap

            Add-PCXCMPackageProgram -PackageName $PackageName -Type "Install" -CommandLine $InstallCommand -Platforms $Platforms
            Add-PCXCMPackageProgram -PackageName $PackageName -Type "Available" -CommandLine $InstallCommand -Platforms $Platforms
            Add-PCXCMPackageProgram -PackageName $PackageName -Type "Uninstall" -CommandLine $UninstallCommand -Platforms $Platforms

            if (Test-PCXCMUpgradeSupported -FileMap $FileMap) {

                $UpgradeCommand = Get-PCXCMCommandLineForPackage -Type "Upgrade" -Installer $Installer -FileMap $FileMap

                if ($UpgradeCommand) {  
                    Add-PCXCMPackageProgram -PackageName $PackageName -Type "Upgrade" -CommandLine $UpgradeCommand -Platforms $Platforms
                }
            }

            Add-PCXCMPackageProgram -PackageName $PackageName -Type "OSD" -CommandLine $OSDCommand -Platforms $Platforms

            New-PCXCMDeploymentDeviceCollections -Collections $Collections -LimitingCollectionName $LimitingCollectionName
            $DeadlineTime = (Get-Date -Hour 10 -Minute 0 -Second 0).AddDays(7)
            New-PCXCMPackageDeployments -PackageName $PackageName -Programs $Programs -Collections $Collections -DeadlineTime $DeadlineTime

            $null = Set-PCXCMDeploymentCollectionRules -Collections $Collections
 
            $null = Move-PCXCMCollectionsToFolder -Collections $Collections -Meta $Meta -ObjectName $PackageName
            $null = Move-PCXCMPackageToFolder -Meta $Meta

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


