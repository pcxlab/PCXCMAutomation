function Get-PCXCMCleanupDashboard {

    [CmdletBinding()]
    param()

    begin {

        Write-PCXOperationStart
    }

    process {

        try {

            $ResultApplicationCleanupSummary = Get-PCXCMApplicationCleanupSummary
            $ResultPackageCleanupSummary = Get-PCXCMPackageCleanupSummary
            $ResultCollectionCleanupSummary = Get-PCXCMCollectionCleanupSummary
            $ResultDeploymentCleanupSummary = Get-PCXCMDeploymentCleanupSummary
            $ResultTaskSequenceCleanupSummary = Get-PCXCMTaskSequenceCleanupSummary

            [PSCustomObject]@{

                ApplicationsTotal              = $ResultApplicationCleanupSummary.ApplicationsTotal
                ApplicationsDeleteCandidate    = $ResultApplicationCleanupSummary.ApplicationsDeleteCandidate

                PackagesTotal                  = $ResultPackageCleanupSummary.PackagesTotal
                PackagesDeleteCandidate        = $ResultPackageCleanupSummary.PackagesDeleteCandidate

                CollectionsTotal               = $ResultCollectionCleanupSummary.CollectionsTotal
                CollectionsDeleteCandidate     = $ResultCollectionCleanupSummary.CollectionsDeleteCandidate

                DeploymentsTotal               = $ResultDeploymentCleanupSummary.DeploymentsTotal
                DeploymentsDeleteCandidate     = $ResultDeploymentCleanupSummary.DeploymentsDeleteCandidate

                TaskSequencesTotal             = $ResultTaskSequenceCleanupSummary.TaskSequencesTotal
                TaskSequencesDeleteCandidate   = $ResultTaskSequenceCleanupSummary.TaskSequencesDeleteCandidate
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