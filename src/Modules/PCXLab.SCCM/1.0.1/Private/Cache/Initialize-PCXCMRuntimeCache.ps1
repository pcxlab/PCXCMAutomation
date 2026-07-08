function Initialize-PCXCMRuntimeCache {

    if (-not $Global:PCXCMRuntimeCache) {

        $Global:PCXCMRuntimeCache = @{
            Collections             = $null
            Applications            = $null
            Packages                = $null
            Deployments             = $null
            DistributionStatus      = $null
            TaskSequences           = $null
            TaskSequenceDeployments = $null
            DistributionPoints      = $null
            DistributionPointGroups = $null
            CloudManagementGateways = $null
        }
    }
}
