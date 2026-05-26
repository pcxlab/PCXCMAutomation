function Start-SCCMContentDistribution {
    param(
        [Parameter(Mandatory)]
        [string]$PackageName,

        [Parameter(Mandatory = $false)]
        [string]$DistributionPointGroupName = "All Mangalore DPs"
    )

    Start-CMContentDistribution `
        -PackageName $PackageName `
        -DistributionPointGroupName $DistributionPointGroupName

    Write-PCXLog "Content distributed to DP Group: $DistributionPointGroupName"
}