function Clear-PCXCMConnection {

    [CmdletBinding()]
    param()

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