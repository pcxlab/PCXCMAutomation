function Get-PCXCMDeploymentCollectionMemberCount {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        $Deployment
    )

    try {

        $Collection = Get-CMCollection `
            -Id $Deployment.CollectionID `
            -ErrorAction SilentlyContinue

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