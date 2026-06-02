function Test-PCXCMConnection {

    [CmdletBinding()]
    param()

    try {

        $drive = Get-PSDrive -PSProvider CMSite -ErrorAction Stop

        if (-not $drive) {
            return $false
        }

        return $true
    }
    catch {
        return $false
    }
}