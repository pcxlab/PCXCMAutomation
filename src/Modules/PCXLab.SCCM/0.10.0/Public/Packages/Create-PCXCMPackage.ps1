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
        try {

            $files = Test-PCXPackagePath $Path
            $installer = Get-PCXInstaller $files

            $meta = Get-PCXMetadataFromPath $Path
            $PackageName = "PKG $($meta.Name)"

            $programs = Get-PCXProgramNames -PackageName $PackageName
            $Collections = Get-PCXCollectionNames -PackageName $PackageName

            Write-PCXLog "Package: $PackageName"
            Write-PCXLog "Installer: $($installer.Name)"

            $null = Connect-PCXCMSite

            $platforms = Get-CMSupportedPlatform -Fast | Where-Object { $_.DisplayText -like "*Windows 11*" }

            Invoke-PCXWithRetry {
                $null = New-CMPackage -Name $PackageName -Manufacturer $meta.Company -Version $meta.Version -Language $Language -Path $Path
            }

            Write-PCXLog "Package created"

            <#
            

            Add-PCXProgram $PackageName "Install" (Get-PCXCommandLineForPackage $Path "Install" $installer) $platforms
            Add-PCXProgram -PackageName $PackageName -Type "Available" -CommandLine (Get-PCXCommandLineForPackage $Path "Install" $installer) -Platforms $platforms
            Add-PCXProgram $PackageName "Uninstall" (Get-PCXCommandLineForPackage $Path "Uninstall" $installer) $platforms

            if (Test-PCXHasUpgrade $Path) {
                $upCmd = Get-PCXCommandLineForPackage $Path "Upgrade" $installer

                if ($upCmd) {
                    Add-PCXProgram $PackageName "Upgrade" $upCmd $platforms
                }
            }

            Add-PCXProgram $PackageName "OSD" (Get-PCXCommandLineForPackage $Path "OSD" $installer) $platforms

            Start-PCXCMContentDistribution -PackageName $PackageName -DistributionPointGroupName $DPGroup

            New-PCXCollections -Collections $Collections -LimitingCollectionName $LimitingCollectionName
            $DeadlineTime = (Get-Date -Hour 20 -Minute 0 -Second 0).AddDays(30)
            New-PCXDeployments -PackageName $PackageName -Programs $programs -Collections $Collections -DeadlineTime $DeadlineTime

            Set-PCXCollectionRules -Collections $Collections

            Move-PCXCMCollectionsToFolder -Collections $Collections -Meta $meta -ObjectName $PackageName
            Move-PCXCMPackageToFolder -Meta $meta

            #>

            Write-PCXLog "SUCCESS: $PackageName"
        }
        catch {
            Write-PCXLog "FAILED: $($_.Exception.Message)" "ERROR"
            Write-PCXOperationEnd -Status Failed
            throw
        }
        finally {
        }
    }
    end {
        Write-PCXOperationEnd
    }
}