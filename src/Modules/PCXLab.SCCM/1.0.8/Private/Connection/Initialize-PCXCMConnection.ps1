function Initialize-PCXCMConnection {

    [CmdletBinding()]
    param()

    if (-not $script:PCXCMConnection) {

        $script:PCXCMConnection = [PSCustomObject]@{
            Connected           = $false
            SiteCode            = $null
            ProviderMachineName = $null
            DriveName           = $null
            DriveRoot           = $null
            ConnectedTime       = $null
            ConnectionMethod    = $null
        }
    }

    return $script:PCXCMConnection
}