function Get-PCXCMDeploymentCleanupRecommendation {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [int]$CollectionMemberCount,

        [Parameter(Mandatory)]
        [int]$NumberTargeted,

        [Parameter(Mandatory)]
        [bool]$Enabled
    )

    if (
        $CollectionMemberCount -eq 0 -and
        $NumberTargeted -eq 0 -and
        -not $Enabled
    ) {
        return 'DELETE_CANDIDATE'
    }

    if (
        $CollectionMemberCount -eq 0 -or
        $NumberTargeted -eq 0
    ) {
        return 'REVIEW'
    }

    return 'KEEP'
}