function New-PCXCMApplicationCleanupObject {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        $Application,

        [Parameter(Mandatory)]
        [int]$DeploymentCount,

        [Parameter(Mandatory)]
        [int]$CollectionCount,

        [Parameter(Mandatory)]
        [int]$DependencyCount,

        [Parameter(Mandatory)]
        [int]$SupersedenceCount,

        [Parameter(Mandatory)]
        [int]$TaskSequenceReferenceCount,

        [Parameter()]
        [int]$LastModifiedAgeDays,

        [Parameter(Mandatory)]
        [string]$RiskLevel,

        [Parameter(Mandatory)]
        [string]$Recommendation
    )

    [PSCustomObject]@{
        ApplicationName          = $Application.LocalizedDisplayName
        CI_ID                    = $Application.CI_ID
        Manufacturer             = $Application.Manufacturer
        SoftwareVersion          = $Application.SoftwareVersion
        DateCreated              = $Application.DateCreated
        DateLastModified         = $Application.DateLastModified
        DeploymentCount          = $DeploymentCount
        CollectionCount          = $CollectionCount
        DependencyCount          = $DependencyCount
        SupersedenceCount        = $SupersedenceCount
        TaskSequenceReferences   = $TaskSequenceReferenceCount
        LastModifiedAgeDays      = $LastModifiedAgeDays
        RiskLevel                = $RiskLevel
        Recommendation           = $Recommendation
    }
}