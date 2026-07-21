function Get-PCXCMApplicationCleanupScore {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [int]$DeploymentCount,

        [Parameter(Mandatory)]
        [int]$CollectionCount,

        [Parameter(Mandatory)]
        [int]$TaskSequenceReferenceCount,

        [Parameter()]
        [int]$DependencyCount,

        [Parameter()]
        [int]$SupersedenceCount,

        [Parameter()]
        [int]$LastModifiedAgeDays
    )

    $Score = 0

    if ($DeploymentCount -eq 0) {
        $Score += 25
    }

    if ($CollectionCount -eq 0) {
        $Score += 20
    }

    if ($TaskSequenceReferenceCount -eq 0) {
        $Score += 25
    }

    if ($DependencyCount -eq 0) {
        $Score += 10
    }

    if ($SupersedenceCount -eq 0) {
        $Score += 5
    }

    if ($LastModifiedAgeDays -ge 365) {
        $Score += 15
    }

    return $Score
}
