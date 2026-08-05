function Test-PCXCMContentDistributionInput {

    param(
        [string[]]$DistributionPointGroups,
        [string[]]$DistributionPoints
    )

    if (-not $DistributionPointGroups -and -not $DistributionPoints) {
        throw "At least one Distribution Point Group or Distribution Point must be specified."
    }

    [PSCustomObject]@{
        DistributionPointGroups = $DistributionPointGroups
        DistributionPoints      = $DistributionPoints
        TotalTargets            = (
            @($DistributionPointGroups).Count +
            @($DistributionPoints).Count
        )
    }
}