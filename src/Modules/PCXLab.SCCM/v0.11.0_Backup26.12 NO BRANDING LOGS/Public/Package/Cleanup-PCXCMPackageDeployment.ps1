function Cleanup-PCXCMPackageDeployment {

    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory, ParameterSetName = 'PackageName')]
        [string]$PackageName,

        [Parameter(Mandatory, ParameterSetName = 'PackagePath')]
        [string]$PackagePath
    )

    begin {
        Write-PCXOperationStart
    }

    process {
        try {
            # Retrieve cleanup info once
            $params = if ($PSCmdlet.ParameterSetName -eq 'PackageName') { @{ PackageName = $PackageName } } else { @{ PackagePath = $PackagePath } }
            $CleanupInfo = Get-PCXCMPackageCleanupInfo @params

            Write-PCXLog -Message "Cleaning Package Deployment: $($CleanupInfo.Package.Name)"

            # Perform removals with ShouldProcess support
            if ($CleanupInfo.Collections) {
                Remove-PCXCMDeviceCollection -CleanupInfo $CleanupInfo
            }

            Remove-PCXCMPackage -CleanupInfo $CleanupInfo

            if ($CleanupInfo.CollectionFolderID) {
                try {
                    Remove-PCXCMDeviceCollectionFolder -CleanupInfo $CleanupInfo
                }
                catch {
                    Write-PCXLog -Message "Collection Folder Cleanup Skipped: $($_.Exception.Message)" -Level WARNING
                }
            }
        }
        catch {
            Write-PCXLog -Message "Cleanup failed: $($_.Exception.Message)" -Level ERROR
            throw
        }
    }

    end {
        Write-PCXOperationEnd
    }
}