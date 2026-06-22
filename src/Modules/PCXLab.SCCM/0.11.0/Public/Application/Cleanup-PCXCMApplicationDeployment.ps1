function Cleanup-PCXCMApplicationDeployment {

    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory, ParameterSetName = 'ApplicationName')]
        [string]$ApplicationName,

        [Parameter(Mandatory, ParameterSetName = 'ApplicationPath')]
        [string]$ApplicationPath
    )

    begin {
        Write-PCXOperationStart
    }

    process {

        try {

            if ($PSCmdlet.ParameterSetName -eq 'ApplicationName') {
                $CleanupInfo = Get-PCXCMApplicationCleanupInfo -ApplicationName $ApplicationName
            }
            else {
                $CleanupInfo = Get-PCXCMApplicationCleanupInfo -ApplicationPath $ApplicationPath
            }

            Write-PCXLog -Message "Cleaning Application Deployment: $($CleanupInfo.ApplicationName)"

            if ($CleanupInfo.Deployments) {
                Remove-PCXCMApplicationDeployment -CleanupInfo $CleanupInfo -WhatIf:$WhatIfPreference
            }

            if (@($CleanupInfo.Collections).Count -gt 0) {
                Remove-PCXCMDeviceCollection -CleanupInfo $CleanupInfo -WhatIf:$WhatIfPreference
            }

            Remove-PCXCMApplication -CleanupInfo $CleanupInfo -WhatIf:$WhatIfPreference

            if ($CleanupInfo.CollectionFolderID) {
                try {
                    Remove-PCXCMDeviceCollectionFolder -CleanupInfo $CleanupInfo -WhatIf:$WhatIfPreference
                }
                catch {
                    Write-PCXLog -Message "Collection Folder Cleanup Skipped: $($_.Exception.Message)" -Level WARNING
                }
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
