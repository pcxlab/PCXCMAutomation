function Set-PCXCMConnection {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$SiteCode,

        [Parameter(Mandatory)]
        [string]$ProviderMachineName,

        [Parameter(Mandatory)]
        [string]$DriveName,

        [Parameter(Mandatory)]
        [string]$DriveRoot,

        [Parameter(Mandatory)]
        [string]$ConnectionMethod
    )

    $null = Initialize-PCXCMConnection 

    $script:PCXCMConnection.Connected           = $true
    $script:PCXCMConnection.SiteCode            = $SiteCode
    $script:PCXCMConnection.ProviderMachineName = $ProviderMachineName
    $script:PCXCMConnection.DriveName           = $DriveName
    $script:PCXCMConnection.DriveRoot           = $DriveRoot
    $script:PCXCMConnection.ConnectedTime       = Get-Date
    $script:PCXCMConnection.ConnectionMethod    = $ConnectionMethod

    return $script:PCXCMConnection
}