function Test-PCXCMConnection {

    [CmdletBinding()]
    param()

    try {

        if (-not $script:PCXCMConnection) {
            return $false
        }

        if (-not $script:PCXCMConnection.Connected) {
            return $false
        }

        $Drive = Get-PSDrive `
            -Name $script:PCXCMConnection.DriveName `
            -PSProvider CMSite `
            -ErrorAction SilentlyContinue

        if (-not $Drive) {
            return $false
        }

        $CurrentLocation = Get-Location

        if (-not $CurrentLocation.Drive) {
            return $false
        }

        return ($CurrentLocation.Drive.Name -eq $script:PCXCMConnection.DriveName)
    }
    catch {
        return $false
    }
}