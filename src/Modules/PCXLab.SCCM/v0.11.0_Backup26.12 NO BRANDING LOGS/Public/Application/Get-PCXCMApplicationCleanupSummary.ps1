function Get-PCXCMApplicationCleanupSummary {

    [CmdletBinding()]
    param(
        [string]$Name = '*'
    )

    begin {

        Write-PCXOperationStart
    }

    process {

        try {

            $ResultApplicationCleanupReport = Get-PCXCMApplicationCleanupReport `
                -Name $Name

            [PSCustomObject]@{
                ApplicationsTotal           = @($ResultApplicationCleanupReport).Count

                ApplicationsKeep            = @(
                    $ResultApplicationCleanupReport |
                    Where-Object Recommendation -eq 'KEEP'
                ).Count

                ApplicationsReview          = @(
                    $ResultApplicationCleanupReport |
                    Where-Object Recommendation -eq 'REVIEW'
                ).Count

                ApplicationsDeleteCandidate = @(
                    $ResultApplicationCleanupReport |
                    Where-Object Recommendation -eq 'DELETE_CANDIDATE'
                ).Count

                ApplicationsHighRisk        = @(
                    $ResultApplicationCleanupReport |
                    Where-Object Risk -eq 'High'
                ).Count

                ApplicationsMediumRisk      = @(
                    $ResultApplicationCleanupReport |
                    Where-Object Risk -eq 'Medium'
                ).Count

                ApplicationsLowRisk         = @(
                    $ResultApplicationCleanupReport |
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