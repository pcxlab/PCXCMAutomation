function Ensure-PCXCMConnection {

    [CmdletBinding()]
    param()

    $null = Initialize-PCXCMConnection

    if (Test-PCXCMConnection) {
        return
    }

    Write-PCXLog `
        -Message "No active SCCM connection found. Connecting..."

    $null = Connect-PCXCMSite

    if (-not (Test-PCXCMConnection)) {
        throw "Failed to establish an SCCM connection."
    }

    Write-PCXLog `
        -Message "SCCM connection established."
}