function Get-PCXCMCollectionDeploymentCount {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        $Collection,

        [Parameter(Mandatory)]
        $Deployments
    )

    try {

        $ResultDeployments = $Deployments | Where-Object {
            $_.CollectionID -eq $Collection.CollectionID
        }

        return @($ResultDeployments).Count
    }
    catch {

        Write-PCXLog `
            -Message $_.Exception.Message `
            -Level ERROR

        throw
    }
}
