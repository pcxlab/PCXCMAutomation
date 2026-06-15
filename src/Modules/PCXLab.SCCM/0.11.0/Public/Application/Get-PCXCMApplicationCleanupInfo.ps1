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

            $AllApplications = Get-PCXCMCachedApplication

            if ($PSCmdlet.ParameterSetName -eq 'ApplicationName') {
                $Application = $AllApplications | Where-Object { $_.LocalizedDisplayName -eq $ApplicationName } | Select-Object -First 1
            }
            else {
                $Application = $AllApplications | Where-Object { $_.SDMPackageXML -match [regex]::Escape($ApplicationPath) } | Select-Object -First 1
            }

            if (-not $Application) {
                throw 'Application not found.'
            }

            if (@($Application).Count -gt 1) {
                throw 'Multiple applications found.'
            }

            Write-PCXLog -Message "Resolved Application: $($Application.LocalizedDisplayName)"

            $Deployments = Get-PCXCMCachedDeployment | Where-Object {
                $_.SoftwareName -eq $Application.LocalizedDisplayName
            }

            Write-PCXLog -Message "Found $(@($Deployments).Count) Deployment(s)"

            $Collections = Get-PCXCMCachedCollection | Where-Object {
                $_.Name -like "$($Application.LocalizedDisplayName)*"
            }

            Write-PCXLog -Message "Found $(@($Collections).Count) Collection(s)"

            $CollectionFolder = Get-PCXCMCollectionFolder -Name $Application.LocalizedDisplayName

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
