function New-PCXCMDeploymentCollectionNames {
    param(
        [Parameter(Mandatory)]
        [string]$ObjectName
    )

    return [PSCustomObject]@{
        Available = "$ObjectName [AVAILABLE]"
        Install   = "$ObjectName [INSTALL]"
        Uninstall = "$ObjectName [UNINSTALL]"
        Exception = "$ObjectName [EXCLUDE]"
    }
}


