function Remove-PCXCMPackage {

    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [psobject]$CleanupInfo
    )

    begin {
        Write-PCXOperationStart
    }
    process {
        try {
            Ensure-PCXCMConnection

            if (-not $CleanupInfo.PackageID) {
                throw "PackageID not found in cleanup info."
            }

            if ($PSCmdlet.ShouldProcess($CleanupInfo.Package.Name, 'Remove Package')) {

                Write-PCXLog -Message "Removing Package: $($CleanupInfo.Package.Name) [$($CleanupInfo.PackageID)]"

                Remove-CMPackage -Id $CleanupInfo.PackageID -Force -ErrorAction Stop

                Write-PCXLog -Message "Removed Package: $($CleanupInfo.Package.Name)"
            }
        }
        catch {
            Write-PCXLog -Message "Failed to remove package. $($_.Exception.Message)" -Level ERROR
            throw
        }
    }
    end {
        Write-PCXOperationEnd
    }
}
