function Get-PCXCMDefaultLimitingCollection {

    [CmdletBinding()]
    param()

    try {

        $CollectionName = Get-PCXCMSetting -Name "Collections.DefaultLimitingCollection"

        if ([string]::IsNullOrWhiteSpace($CollectionName)) {

            Write-PCXLog -Message "DefaultLimitingCollection not configured. Using 'All Systems'." -Level Warning

            return "All Systems"
        }

        if ($CollectionName -eq "All Systems") {

            Write-PCXLog -Message "Default limiting collection is configured as 'All Systems'. Consider changing this to an environment-specific limiting collection." -Level Warning
        }

        return $CollectionName
    }
    catch {

        Write-PCXLog -Message "Failed to read DefaultLimitingCollection. Using 'All Systems'." -Level Warning

        return "All Systems"
    }
}