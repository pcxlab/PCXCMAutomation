function Get-PCXCMDeploymentCollectionMemberCount {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        $Deployment,

        [Parameter(Mandatory)]
        $Collections
    )

    try {

        $Collection = $Collections | Where-Object {
            $_.CollectionID -eq $Deployment.CollectionID
        } | Select-Object -First 1

        if (-not $Collection) {
            return 0
        }

        return [int]$Collection.MemberCount
    }
    catch {

        Write-PCXLog -Message $_.Exception.Message -Level ERROR
        throw
    }
}
