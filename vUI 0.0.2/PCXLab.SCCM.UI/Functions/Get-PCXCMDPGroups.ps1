function Get-PCXCMDPGroups {

    [CmdletBinding()]
    param()

    #
    # TEMPORARY
    # Replace with SCCM query later
    #

    @(
        "All Mangalore DPs"
        "Pilot DPs"
        "Test DPs"
    )
}

<#
function Get-PCXCMDPGroups {

    Get-CMDistributionPointGroup |
        Sort-Object Name |
        Select-Object -ExpandProperty Name
}
#>