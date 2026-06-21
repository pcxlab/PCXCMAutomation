function Get-PCXCMSiteDrive {

    [CmdletBinding()]
    param()

    try {

        if (-not (Get-Module ConfigurationManager)) {
            Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1" -ErrorAction Stop
        }

        $currentLocation = Get-Location

        if (
            $currentLocation.Drive -and
            $currentLocation.Drive.Provider -and
            $currentLocation.Drive.Provider.Name -eq 'CMSite'
        ) {
            return $currentLocation.Drive.Name
        }

        throw "Current location is not a CMSite drive."
    }
    catch {
        throw "Unable to detect Configuration Manager site drive. $($_.Exception.Message)"
    }
}