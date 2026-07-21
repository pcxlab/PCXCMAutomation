function Get-PCXCMDeploymentCleanupScore {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [int]$CollectionMemberCount,

        [Parameter(Mandatory)]
        [int]$NumberTargeted,

        [Parameter(Mandatory)]
        [bool]$Enabled
    )

    $Score = 100

    if ($CollectionMemberCount -eq 0) {
        $Score -= 40
    }

    if ($NumberTargeted -eq 0) {
        $Score -= 40
    }

    if (-not $Enabled) {
        $Score -= 20
    }

    return $Score
}
