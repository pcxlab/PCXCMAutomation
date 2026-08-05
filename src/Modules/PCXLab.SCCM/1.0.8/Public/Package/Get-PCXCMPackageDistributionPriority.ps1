function Get-PCXCMPackageDistributionPriority {

    [CmdletBinding()]
    param()

    $Priority = Get-PCXCMSetting -Name "Package.DistributionSettings.Priority"

    if ([string]::IsNullOrWhiteSpace($Priority)) {
        Write-PCXLog "Package Distribution Priority not configured. Using Medium." -Level Warning
        return "Normal"
    }

    switch ($Priority.ToLower()) {

        "high"   { return "High" }

        "medium" { return "Normal" }

        "low"    { return "Low" }

        default {
            Write-PCXLog "Invalid Package Distribution Priority '$Priority'. Using Medium." -Level Warning
            return "Normal"
        }
    }
}