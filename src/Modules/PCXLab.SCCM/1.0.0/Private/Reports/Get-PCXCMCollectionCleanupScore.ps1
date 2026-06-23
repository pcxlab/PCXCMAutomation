function Get-PCXCMCollectionCleanupScore {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [int]$MemberCount,

        [Parameter(Mandatory)]
        [int]$DeploymentCount
    )

    try {

        $Score = 0

        if ($MemberCount -eq 0) {
            $Score += 50
        }

        if ($DeploymentCount -eq 0) {
            $Score += 50
        }

        return $Score
    }
    catch {

        Write-PCXLog -Message $_.Exception.Message -Level ERROR
        throw
    }
}
