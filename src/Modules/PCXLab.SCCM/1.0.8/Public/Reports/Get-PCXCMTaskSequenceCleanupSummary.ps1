function Get-PCXCMTaskSequenceCleanupSummary {

    [CmdletBinding()]
    param(
        [string]$Name = '*'
    )

    begin {

        Write-PCXOperationStart
    }

    process {

        try {

            $ResultTaskSequenceCleanupReport = Get-PCXCMTaskSequenceCleanupReport `
                -Name $Name

            [PSCustomObject]@{
                TaskSequencesTotal           = @($ResultTaskSequenceCleanupReport).Count

                TaskSequencesKeep            = @(
                    $ResultTaskSequenceCleanupReport |
                    Where-Object Recommendation -eq 'KEEP'
                ).Count

                TaskSequencesReview          = @(
                    $ResultTaskSequenceCleanupReport |
                    Where-Object Recommendation -eq 'REVIEW'
                ).Count

                TaskSequencesDeleteCandidate = @(
                    $ResultTaskSequenceCleanupReport |
                    Where-Object Recommendation -eq 'DELETE_CANDIDATE'
                ).Count

                TaskSequencesHighRisk        = @(
                    $ResultTaskSequenceCleanupReport |
                    Where-Object Risk -eq 'High'
                ).Count

                TaskSequencesMediumRisk      = @(
                    $ResultTaskSequenceCleanupReport |
                    Where-Object Risk -eq 'Medium'
                ).Count

                TaskSequencesLowRisk         = @(
                    $ResultTaskSequenceCleanupReport |
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
