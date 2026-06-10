function Get-PCXCMApplicationCleanupReport {

    [CmdletBinding()]
    param(
        [string]$Name = '*'
    )

    begin {

        Write-PCXOperationStart
    }

    process {

        try {

            Ensure-PCXCMConnection

            $Applications = Get-CMApplication `
                -Name $Name `
                -Fast

            foreach ($Application in $Applications) {

                $DeploymentCount = Get-PCXCMApplicationDeploymentCount `
                    -Application $Application

                $CollectionCount = Get-PCXCMApplicationCollectionCount `
                    -Application $Application

                $DeploymentTypeCount = Get-PCXCMApplicationDeploymentTypeCount `
                    -Application $Application  

                $DependencyCount = Get-PCXCMApplicationDependencyCount `
                    -Application $Application

                $SupersedenceCount = Get-PCXCMApplicationSupersedenceCount `
                    -Application $Application

                $TaskSequenceReferenceCount = Get-PCXCMApplicationTaskSequenceReferenceCount `
                    -Application $Application

                $LastModifiedAgeDays = Get-PCXCMApplicationLastModifiedAge `
                    -Application $Application
                    
                $EnabledStatus = Get-PCXCMApplicationEnabledStatus `
                    -Application $Application

                $ExpiredStatus = Get-PCXCMApplicationExpiredStatus `
                    -Application $Application
                
                $DeployedStatus = Get-PCXCMApplicationDeployedStatus `
    -Application $Application

                $CleanupScore = Get-PCXCMApplicationCleanupScore `
                    -DeploymentCount $DeploymentCount `
                    -CollectionCount $CollectionCount `
                    -TaskSequenceReferenceCount $TaskSequenceReferenceCount `
                    -DependencyCount $DependencyCount `
                    -SupersedenceCount $SupersedenceCount `
                    -LastModifiedAgeDays $LastModifiedAgeDays

                $Recommendation = Get-PCXCMApplicationCleanupRecommendation `
                    -DeploymentCount $DeploymentCount `
                    -CollectionCount $CollectionCount `
                    -TaskSequenceReferenceCount $TaskSequenceReferenceCount `
                    -LastModifiedAgeDays $LastModifiedAgeDays

                $Risk = Get-PCXCMCleanupRisk `
                    -Recommendation $Recommendation

                [PSCustomObject]@{
                    ApplicationName          = $Application.LocalizedDisplayName
                    CI_ID                    = $Application.CI_ID
                    Manufacturer             = $Application.Manufacturer
                    SoftwareVersion          = $Application.SoftwareVersion

                    EnabledStatus            = $EnabledStatus
                    ExpiredStatus            = $ExpiredStatus
                    DeployedStatus           = $DeployedStatus

                    DateCreated              = $Application.DateCreated
                    DateLastModified         = $Application.DateLastModified

                    DeploymentCount          = $DeploymentCount
                    CollectionCount          = $CollectionCount
                    DeploymentTypeCount      = $DeploymentTypeCount
                    DependencyCount          = $DependencyCount
                    SupersedenceCount        = $SupersedenceCount
                    TaskSequenceReferences   = $TaskSequenceReferenceCount

                    CleanupScore             = $CleanupScore
                    Risk                     = $Risk
                    Recommendation           = $Recommendation
                }
            }
        }
        catch {

            Write-PCXLog -Message $_.Exception.Message -Level ERROR
            throw
        }
    }

    end {

        Write-PCXOperationEnd
    }
}