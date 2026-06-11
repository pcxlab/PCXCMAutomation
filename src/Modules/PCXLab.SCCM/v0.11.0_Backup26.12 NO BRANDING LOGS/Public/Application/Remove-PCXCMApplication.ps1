function Remove-PCXCMApplication {

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

            if (-not $CleanupInfo.ApplicationCIID) {
                throw 'ApplicationCIID not found.'
            }

            if ($PSCmdlet.ShouldProcess($CleanupInfo.ApplicationName, 'Remove Application')) {
                Write-PCXLog -Message "Removing Application: $($CleanupInfo.ApplicationName) [$($CleanupInfo.ApplicationCIID)]"
                Remove-CMApplication -Id $CleanupInfo.ApplicationCIID -Force -ErrorAction Stop
                Write-PCXLog -Message "Removed Application: $($CleanupInfo.ApplicationName) [$($CleanupInfo.ApplicationCIID)]"
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