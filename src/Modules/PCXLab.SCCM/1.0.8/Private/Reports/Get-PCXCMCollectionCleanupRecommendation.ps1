function Get-PCXCMCollectionCleanupRecommendation {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [int]$MemberCount,

        [Parameter(Mandatory)]
        [int]$DeploymentCount
    )

    try {

        if (
            $MemberCount -eq 0 -and
            $DeploymentCount -eq 0
        ) {
            return 'DELETE_CANDIDATE'
        }

        if (
            $MemberCount -gt 0 -and
            $DeploymentCount -gt 0
        ) {
            return 'KEEP'
        }

        return 'REVIEW'
    }
    catch {

        Write-PCXLog -Message $_.Exception.Message -Level ERROR
        throw
    }
}
