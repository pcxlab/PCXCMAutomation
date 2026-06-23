function Get-PCXCMDeploymentCleanupReport {

    [CmdletBinding()]
    param()

    begin {

        Write-PCXOperationStart
    }

    process {

        try {

            $Collections = Get-PCXCMCachedCollection

            $Deployments = Get-PCXCMCachedDeployment

            foreach ($Deployment in $Deployments) {

                $DeploymentIntentName = Get-PCXCMDeploymentIntentName `
                    -DeploymentIntent $Deployment.DeploymentIntent

                $CollectionMemberCount = Get-PCXCMDeploymentCollectionMemberCount `
                    -Deployment $Deployment `
                    -Collections $Collections

                $Enabled = Get-PCXCMDeploymentEnabledStatus `
                    -Deployment $Deployment

                $DeploymentAgeDays = Get-PCXCMDeploymentAge `
                    -Deployment $Deployment

                $CleanupScore = Get-PCXCMDeploymentCleanupScore `
                    -CollectionMemberCount $CollectionMemberCount `
                    -NumberTargeted $Deployment.NumberTargeted `
                    -Enabled $Enabled

                $Recommendation = Get-PCXCMDeploymentCleanupRecommendation `
                    -CollectionMemberCount $CollectionMemberCount `
                    -NumberTargeted $Deployment.NumberTargeted `
                    -Enabled $Enabled

                $Risk = Get-PCXCMCleanupRisk `
                    -Recommendation $Recommendation

                [PSCustomObject]@{
                    ApplicationName       = $Deployment.ApplicationName
                    DeploymentID          = $Deployment.DeploymentID

                    DeploymentIntent      = $DeploymentIntentName

                    CollectionName        = $Deployment.CollectionName
                    CollectionID          = $Deployment.CollectionID

                    CollectionMemberCount = $CollectionMemberCount

                    NumberTargeted        = $Deployment.NumberTargeted
                    NumberSuccess         = $Deployment.NumberSuccess
                    NumberErrors          = $Deployment.NumberErrors

                    Enabled               = $Enabled

                    DeploymentAgeDays     = $DeploymentAgeDays

                    CleanupScore          = $CleanupScore
                    Risk                  = $Risk
                    Recommendation        = $Recommendation
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
