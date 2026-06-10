function Get-PCXCMApplicationRecommendation {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$RiskLevel
    )

    switch ($RiskLevel) {

        'KEEP' {
            return 'KEEP'
        }

        'REVIEW' {
            return 'REVIEW'
        }

        'DELETE_CANDIDATE' {
            return 'DELETE_CANDIDATE'
        }

        default {
            return 'REVIEW'
        }
    }
}