function Get-PCXCMPackageCleanupSummary {

    [CmdletBinding()]
    param(
        [string]$Name = '*'
    )

    begin {

        Write-PCXOperationStart
    }

    process {

        try {

            $ResultPackageCleanupReport = Get-PCXCMPackageCleanupReport `
                -Name $Name

            [PSCustomObject]@{
                PackagesTotal           = @($ResultPackageCleanupReport).Count

                PackagesKeep            = @(
                    $ResultPackageCleanupReport |
                    Where-Object Recommendation -eq 'KEEP'
                ).Count

                PackagesReview          = @(
                    $ResultPackageCleanupReport |
                    Where-Object Recommendation -eq 'REVIEW'
                ).Count

                PackagesDeleteCandidate = @(
                    $ResultPackageCleanupReport |
                    Where-Object Recommendation -eq 'DELETE_CANDIDATE'
                ).Count

                PackagesHighRisk        = @(
                    $ResultPackageCleanupReport |
                    Where-Object Risk -eq 'High'
                ).Count

                PackagesMediumRisk      = @(
                    $ResultPackageCleanupReport |
                    Where-Object Risk -eq 'Medium'
                ).Count

                PackagesLowRisk         = @(
                    $ResultPackageCleanupReport |
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
