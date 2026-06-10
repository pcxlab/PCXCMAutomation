function Get-PCXCMApplicationDetails {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        $Application
    )

    [PSCustomObject]@{
        ApplicationName = $Application.LocalizedDisplayName
        CI_ID           = $Application.CI_ID
        ModelName       = $Application.ModelName
        Manufacturer    = $Application.Manufacturer
        SoftwareVersion = $Application.SoftwareVersion
        DateCreated     = $Application.DateCreated
        DateLastModified= $Application.DateLastModified
        IsEnabled       = $Application.IsEnabled
        IsExpired       = $Application.IsExpired
    }
}