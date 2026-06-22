function Test-PCXCMConnection {

    [CmdletBinding()]
    param()

    try {

        $SiteCode = Get-PCXCMSiteCode

        $CurrentLocation = Get-Location

        if (
            $CurrentLocation.Drive -and
            $CurrentLocation.Drive.Name -eq $SiteCode
        ) {
            return $true
        }

        return $false
    }
    catch {
        return $false
    }
}
