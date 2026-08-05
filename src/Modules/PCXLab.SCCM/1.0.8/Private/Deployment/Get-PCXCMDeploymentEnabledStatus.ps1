function Get-PCXCMDeploymentEnabledStatus {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        $Deployment
    )

    return [bool]$Deployment.Enabled
}
