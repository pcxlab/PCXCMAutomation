function Get-PCXCMSiteCode {
    [CmdletBinding()]
    param()
    
    if ($script:PCXCMSiteCode) {
        return $script:PCXCMSiteCode
    }

    try {
        $siteObj = Get-CimInstance -Namespace 'Root\SMS' -ClassName SMS_ProviderLocation -ComputerName '.' -ErrorAction Stop
        $code = if ($siteObj -is [array]) { $siteObj[0].SiteCode } else { $siteObj.SiteCode }
        $script:PCXCMSiteCode = $code
        return $code
    } catch {
        Throw "Error retrieving SCCM site code: $($_.Exception.Message)"
    }
}



