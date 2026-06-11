function Remove-PCXCMDeviceCollectionFolder {

    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [psobject]$CleanupInfo
    )

    begin {
        Write-PCXOperationStart
    }
    process {
        try {
            if (-not $CleanupInfo.CollectionFolderID) {
                Write-PCXLog "No collection folder to remove."
                return
            }

            if ($PSCmdlet.ShouldProcess($CleanupInfo.CollectionFolder.Name, 'Remove Collection Folder')) {
                Write-PCXLog -Message "Removing Collection Folder: $($CleanupInfo.CollectionFolder.Name) [$($CleanupInfo.CollectionFolderID)]"

                Remove-CMFolder -Id $CleanupInfo.CollectionFolderID -Force -ErrorAction Stop

                Write-PCXLog -Message "Removed Collection Folder: $($CleanupInfo.CollectionFolder.Name)"
            }
        }
        catch {
            Write-PCXLog -Message "Failed to remove collection folder. $($_.Exception.Message)" -Level ERROR
            throw
        }
    }
    end {
        Write-PCXOperationEnd
    }
}