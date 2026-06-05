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
                throw 'CollectionFolderID not found.'
            }

            if ($PSCmdlet.ShouldProcess($CleanupInfo.CollectionFolder.Name, 'Remove Collection Folder')) {
                Write-PCXLog -Message "Removing Collection Folder: $($CleanupInfo.CollectionFolder.Name) [$($CleanupInfo.CollectionFolderID)]"
                Remove-CMFolder -Id $CleanupInfo.CollectionFolderID -Force -ErrorAction Stop
                Write-PCXLog -Message "Removed Collection Folder: $($CleanupInfo.CollectionFolder.Name) [$($CleanupInfo.CollectionFolderID)]"
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