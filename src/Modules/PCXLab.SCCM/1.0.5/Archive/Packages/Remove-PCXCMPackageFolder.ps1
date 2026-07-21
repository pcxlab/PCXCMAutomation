function Remove-PCXCMPackageFolder {

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

            if (-not $CleanupInfo.PackageFolderID) {
                throw 'PackageFolderID not found.'
            }

            if ($PSCmdlet.ShouldProcess($CleanupInfo.PackageFolder.Name, 'Remove Package Folder')) {

                Write-PCXLog -Message "Removing Package Folder: $($CleanupInfo.PackageFolder.Name) [$($CleanupInfo.PackageFolderID)]"

                Remove-CMFolder -Id $CleanupInfo.PackageFolderID -Force -ErrorAction Stop

                Write-PCXLog -Message "Removed Package Folder: $($CleanupInfo.PackageFolder.Name) [$($CleanupInfo.PackageFolderID)]"
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
