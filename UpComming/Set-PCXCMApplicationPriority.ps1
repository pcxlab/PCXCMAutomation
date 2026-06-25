#function for application Distribution priority

function Set-PCXCMApplicationPriority {
    param(
        [parameter(Mandatory=$true)] [string] $application,
        [parameter(Mandatory=$true)] [string] $DistributionPriority

    )
 Set-CMApplication -Name $application  -DistributionPriority $DistributionPriority

}

#Usage Example
Set-PCXCMApplicationPriority -application "APS_7Zip_TEST1" -DistributionPriority High

#--------------------------------------------------------------------------------------------------