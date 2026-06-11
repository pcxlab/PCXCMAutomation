function Get-PCXCMCollectionCleanupSummary {

    [CmdletBinding()]
    param(
        [string]$Name = '*'
    )

    begin {

        Write-PCXOperationStart
    }

    process {

        try {

            $ResultCollectionCleanupReport = Get-PCXCMCollectionCleanupReport `
                -Name $Name

            [PSCustomObject]@{
                CollectionsTotal           = @($ResultCollectionCleanupReport).Count

                CollectionsKeep            = @(
                    $ResultCollectionCleanupReport |
                    Where-Object Recommendation -eq 'KEEP'
                ).Count

                CollectionsReview          = @(
                    $ResultCollectionCleanupReport |
                    Where-Object Recommendation -eq 'REVIEW'
                ).Count

                CollectionsDeleteCandidate = @(
                    $ResultCollectionCleanupReport |
                    Where-Object Recommendation -eq 'DELETE_CANDIDATE'
                ).Count

                CollectionsHighRisk        = @(
                    $ResultCollectionCleanupReport |
                    Where-Object Risk -eq 'High'
                ).Count

                CollectionsMediumRisk      = @(
                    $ResultCollectionCleanupReport |
                    Where-Object Risk -eq 'Medium'
                ).Count

                CollectionsLowRisk         = @(
                    $ResultCollectionCleanupReport |
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