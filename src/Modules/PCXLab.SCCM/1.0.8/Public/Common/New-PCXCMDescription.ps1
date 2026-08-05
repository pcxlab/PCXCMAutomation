function New-PCXCMDescription {

    [CmdletBinding()]
    [OutputType([string])]
    param(
        [string]$Creator = $env:USERNAME,
        [string]$Reviewer,
        [string]$RequestNumber,
        [string]$Comment
    )

    return (Get-PCXCMDescriptionInformation @PSBoundParameters).Description
}