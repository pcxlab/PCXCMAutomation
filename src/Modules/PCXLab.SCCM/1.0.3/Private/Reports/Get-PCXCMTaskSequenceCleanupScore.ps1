function Get-PCXCMTaskSequenceCleanupScore {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [int]$DeploymentCount,

        [Parameter(Mandatory)]
        [bool]$Enabled
    )

    $Score = 100

    if ($DeploymentCount -eq 0) {
        $Score -= 50
    }

    if (-not $Enabled) {
        $Score -= 50
    }

    return $Score
}
