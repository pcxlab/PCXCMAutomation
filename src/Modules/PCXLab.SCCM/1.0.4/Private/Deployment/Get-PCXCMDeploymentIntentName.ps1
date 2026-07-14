function Get-PCXCMDeploymentIntentName {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [int]$DeploymentIntent
    )

    switch ($DeploymentIntent) {

        1 { return 'Required' }
        2 { return 'Available' }

        default { return "Unknown ($DeploymentIntent)" }
    }
}
