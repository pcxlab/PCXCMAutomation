function Remove-PCXCMDeviceCollection {

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
            Ensure-PCXCMConnection

            $Collections = $CleanupInfo.Collections |
            Sort-Object {
                switch -Regex ($_.Name) {
                    '\[INSTALL\]'   { 1; break }
                    '\[EXCLUDE\]'   { 2; break }
                    '\[UNINSTALL\]' { 3; break }
                    '\[AVAILABLE\]' { 4; break }
                    default         { 99 }
                }
            }

            if (-not $Collections) {
                Write-PCXLog "No collections to remove."
                return
            }

            foreach ($Collection in $Collections) {

                if ($PSCmdlet.ShouldProcess($Collection.Name, 'Remove Collection')) {

                    Write-PCXLog -Message "Removing Collection: $($Collection.Name) [$($Collection.CollectionID)]"

                    Remove-CMDeviceCollection -Id $Collection.CollectionID -Force -ErrorAction Stop

                    Write-PCXLog -Message "Removed Collection: $($Collection.Name)"
                }
            }
        }
        catch {
            Write-PCXLog -Message "Failed to remove collections. $($_.Exception.Message)" -Level ERROR
            throw
        }
    }

    end {
        Write-PCXOperationEnd
    }
}