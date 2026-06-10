function Get-PCXCMApplicationCleanupInfo {

    [CmdletBinding(DefaultParameterSetName = 'ApplicationName')]
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

            Ensure-PCXCMConnection

            if ($PSCmdlet.ParameterSetName -eq 'ApplicationName') {

                $Application = Get-CMApplication -Name $ApplicationName -Fast
            }
            else {

                $Application = Get-CMApplication -Fast | Where-Object {
                    $_.SDMPackageXML -match [regex]::Escape($ApplicationPath)
                }
            }

            if (-not $Application) {
                throw 'Application not found.'
            }

            if (@($Application).Count -gt 1) {
                throw 'Multiple applications found.'
            }

            Write-PCXLog -Message "Resolved Application: $($Application.LocalizedDisplayName)"

            $Deployments = Get-CMApplicationDeployment -Name $Application.LocalizedDisplayName

            Write-PCXLog -Message "Found $(@($Deployments).Count) Deployment(s)"

            $Collections = Get-CMDeviceCollection -Name "$($Application.LocalizedDisplayName)*"

            Write-PCXLog -Message "Found $(@($Collections).Count) Collection(s)"

            $CollectionFolder = Get-CMFolder -Name $Application.LocalizedDisplayName | Where-Object {
                $_.ObjectTypeName -eq 'SMS_Collection_Device'
            }

            if (@($CollectionFolder).Count -gt 1) {
                throw 'Multiple collection folders found.'
            }

            if ($CollectionFolder) {
                Write-PCXLog -Message "Found Collection Folder: $($CollectionFolder.Name)"
            }
            else {
                Write-PCXLog -Message 'Collection Folder Not Found' -Level WARNING
            }

            [PSCustomObject]@{
                Application        = $Application
                ApplicationName    = $Application.LocalizedDisplayName
                ApplicationCIID    = $Application.CI_ID
                Deployments        = $Deployments
                Collections        = $Collections
                CollectionFolder   = $CollectionFolder
                CollectionFolderID = $CollectionFolder.ContainerNodeID
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