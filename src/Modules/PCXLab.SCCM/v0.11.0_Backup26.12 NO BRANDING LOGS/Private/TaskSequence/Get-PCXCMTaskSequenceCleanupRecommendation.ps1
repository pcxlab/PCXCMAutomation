function Get-PCXCMTaskSequenceCleanupRecommendation {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [int]$DeploymentCount,

        [Parameter(Mandatory)]
        [bool]$Enabled
    )

    if (
        $DeploymentCount -eq 0 -and
        -not $Enabled
    ) {
        return 'DELETE_CANDIDATE'
    }

    if (
        $DeploymentCount -eq 0 -or
        -not $Enabled
    ) {
        return 'REVIEW'
    }

    return 'KEEP'
}