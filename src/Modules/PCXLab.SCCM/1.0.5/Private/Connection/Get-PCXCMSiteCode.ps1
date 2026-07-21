function Get-PCXCMSiteCode {

    [CmdletBinding()]
    param()

    $null = Initialize-PCXCMConnection

    if (-not $script:PCXCMConnection.Connected) {
        Ensure-PCXCMConnection
    }

    return $script:PCXCMConnection.SiteCode
}

