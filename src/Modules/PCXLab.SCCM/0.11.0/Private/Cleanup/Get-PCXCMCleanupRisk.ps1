function Get-PCXCMCleanupRisk {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Recommendation
    )

    switch ($Recommendation) {

        'KEEP' {
            return 'Low'
        }

        'REVIEW' {
            return 'Medium'
        }

        'DELETE_CANDIDATE' {
            return 'High'
        }

        default {
            return 'Unknown'
        }
    }
}