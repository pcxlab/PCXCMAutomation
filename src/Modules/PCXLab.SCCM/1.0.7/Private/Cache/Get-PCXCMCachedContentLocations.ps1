function Get-PCXCMCachedContentLocations {

    [CmdletBinding()]
    param()

    $ContentLocations = @()

    foreach ($DistributionPoint in Get-PCXCMCachedDPs) {

        $ContentLocations += [PSCustomObject]@{
            Name    = $DistributionPoint.NetworkOSPath.TrimStart('\')
            Type    = 'DistributionPoint'
            NALPath = $DistributionPoint.NALPath
        }
    }

    foreach ($CloudManagementGateway in Get-PCXCMCachedCloudManagementGateways) {

        $ContentLocations += [PSCustomObject]@{
            Name    = $CloudManagementGateway.ServiceCName
            Type    = 'CloudManagementGateway'
            NALPath = $CloudManagementGateway.NALPath
        }
    }

    return $ContentLocations
}