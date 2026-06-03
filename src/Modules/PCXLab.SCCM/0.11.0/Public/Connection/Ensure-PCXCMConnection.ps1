function Ensure-PCXCMConnection {

    [CmdletBinding()]
    param()

    try {

        if (Test-PCXCMConnection) {
            #Write-PCXLog "Using existing SCCM connection."
            return
        }
        
        Write-PCXLog "Connecting SCCM Site..."
        $null = Connect-PCXCMSite
        Write-PCXLog "Connected SCCM Site."
    }
    catch {
        Write-PCXLog -Message "Failed to establish SCCM connection. $($_.Exception.Message)" -Level ERROR
        throw
    }
}


