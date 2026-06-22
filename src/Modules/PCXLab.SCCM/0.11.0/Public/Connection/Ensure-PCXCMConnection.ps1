function Ensure-PCXCMConnection {

    [CmdletBinding()]
    param()

    begin {
        #Write-PCXOperationStart
    }
    process {
        try {

            if (Test-PCXCMConnection) {
                #Write-PCXLog -Message 'Using existing SCCM connection.'
                return
            }

            #Write-PCXLog -Message 'Establishing SCCM connection.'
            $null = Connect-PCXCMSite

            if (-not (Test-PCXCMConnection)) {
                throw 'Failed to establish SCCM connection.'
            }
            #Write-PCXLog -Message 'SCCM connection established.'
        }
        catch {
            Write-PCXLog -Message $_.Exception.Message -Level ERROR
            throw
        }
    }
    end {
        #Write-PCXOperationEnd
    }
}
