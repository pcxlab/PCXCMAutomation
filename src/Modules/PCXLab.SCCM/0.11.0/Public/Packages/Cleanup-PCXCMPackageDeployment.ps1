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

            if ($PSCmdlet.ParameterSetName -eq 'PackageName') {
                $CleanupInfo = Get-PCXCMPackageCleanupInfo -PackageName $PackageName
            }
            else {
                $CleanupInfo = Get-PCXCMPackageCleanupInfo -PackagePath $PackagePath
            }

            Write-PCXLog -Message "Cleaning Package Deployment: $($CleanupInfo.Package.Name)"

            if (@($CleanupInfo.Collections).Count -gt 0) {
                Remove-PCXCMDeviceCollection -CleanupInfo $CleanupInfo -WhatIf:$WhatIfPreference
            }

            Remove-PCXCMPackage -CleanupInfo $CleanupInfo -WhatIf:$WhatIfPreference

            try {
                Remove-PCXCMDeviceCollectionFolder -CleanupInfo $CleanupInfo -WhatIf:$WhatIfPreference
            }
            catch {
                Write-PCXLog -Message "Collection Folder Cleanup Skipped: $($_.Exception.Message)" -Level WARNING
            }
        }
        catch {
            Write-PCXLog -Message $_.Exception.Message -Level ERROR
            throw
        }
    }
    end {
        Write-PCXOperationEnd
    }
}