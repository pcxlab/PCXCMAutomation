function Set-PCXCMApplicationDistributionPriority {

    <#
    .SYNOPSIS
        Sets the distribution priority for an SCCM application.

    .DESCRIPTION
        Updates the Distribution Priority property of an existing Configuration Manager
        application.

    .PARAMETER Name
        Name of the Configuration Manager application.

    .PARAMETER DistributionPriority
        Distribution priority to assign.

    .EXAMPLE
        Set-PCXCMApplicationDistributionPriority `
            -Name "APS_7Zip_TEST1" `
            -DistributionPriority High

    .NOTES
        Author : PCXLab
    #>

    [CmdletBinding(SupportsShouldProcess)]

    param(

        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias("Application")]
        [ValidateNotNullOrEmpty()]
        [string]$Name,

        [Parameter(Mandatory)]
        [ValidateSet(
            "Low",
            "Medium",
            "High"
        )]
        [string]$DistributionPriority

    )

    process {

        if ($PSCmdlet.ShouldProcess($Name, "Set application distribution priority to '$DistributionPriority'")) {

            Set-CMApplication `
                -Name $Name `
                -DistributionPriority $DistributionPriority
        }

    }

}

<#
Set-PCXCMApplicationDistributionPriority `
    -Name "APS_7Zip_TEST1" `
    -DistributionPriority High


"APS_7Zip_TEST1" | Set-PCXCMApplicationDistributionPriority -DistributionPriority High

#>
