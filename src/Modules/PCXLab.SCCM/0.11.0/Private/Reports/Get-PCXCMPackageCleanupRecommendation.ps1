function Get-PCXCMPackageCleanupRecommendation {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [int]$DeploymentCount,

        [Parameter(Mandatory)]
        [int]$CollectionCount,

        [Parameter(Mandatory)]
        [int]$LastModifiedAgeDays
    )

    if (
        $DeploymentCount -gt 0 -or
        $CollectionCount -gt 0
    ) {
        return 'KEEP'
    }

    if (
        $DeploymentCount -eq 0 -and
        $CollectionCount -eq 0 -and
        $LastModifiedAgeDays -ge 365
    ) {
        return 'DELETE_CANDIDATE'
    }

    return 'REVIEW'
}
