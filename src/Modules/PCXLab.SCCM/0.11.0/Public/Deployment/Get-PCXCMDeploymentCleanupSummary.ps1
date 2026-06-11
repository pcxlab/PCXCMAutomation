function Get-PCXCMDeploymentCleanupSummary {

    [CmdletBinding()]
    param()

    begin {

        Write-PCXOperationStart
    }

    process {

        try {

            $ResultDeploymentCleanupReport = Get-PCXCMDeploymentCleanupReport

            [PSCustomObject]@{
                DeploymentsTotal           = @($ResultDeploymentCleanupReport).Count

                DeploymentsKeep            = @(
                    $ResultDeploymentCleanupReport |
                    Where-Object Recommendation -eq 'KEEP'
                ).Count

                DeploymentsReview          = @(
                    $ResultDeploymentCleanupReport |
                    Where-Object Recommendation -eq 'REVIEW'
                ).Count

                DeploymentsDeleteCandidate = @(
                    $ResultDeploymentCleanupReport |
                    Where-Object Recommendation -eq 'DELETE_CANDIDATE'
                ).Count

                DeploymentsHighRisk        = @(
                    $ResultDeploymentCleanupReport |
                    Where-Object Risk -eq 'High'
                ).Count

                DeploymentsMediumRisk      = @(
                    $ResultDeploymentCleanupReport |
                    Where-Object Risk -eq 'Medium'
                ).Count

                DeploymentsLowRisk         = @(
                    $ResultDeploymentCleanupReport |
                    Where-Object Risk -eq 'Low'
                ).Count
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