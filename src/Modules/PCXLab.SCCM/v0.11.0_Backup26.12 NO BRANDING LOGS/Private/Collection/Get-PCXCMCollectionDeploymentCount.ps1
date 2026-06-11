function Get-PCXCMCollectionDeploymentCount {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        $Collection
    )

    try {

        $Deployments = Get-CMDeployment `
            -ErrorAction SilentlyContinue |
            Where-Object {
                $_.CollectionID -eq $Collection.CollectionID
            }

        return @($Deployments).Count
    }
    catch {

        Write-PCXLog -Message $_.Exception.Message -Level ERROR
        throw
    }
}