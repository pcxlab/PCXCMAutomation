function Reset-PCXCMConnection {

    [CmdletBinding()]
    param()

    $siteCode = Get-PCXCMSiteCode

    if (Get-PSDrive -Name $siteCode -ErrorAction SilentlyContinue) {

        Remove-PSDrive -Name $siteCode -Force
    }

    Connect-PCXCMSite
}
