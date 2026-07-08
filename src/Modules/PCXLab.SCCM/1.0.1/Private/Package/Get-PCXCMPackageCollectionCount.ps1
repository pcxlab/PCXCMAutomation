function Get-PCXCMPackageCollectionCount {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        $Package,

        [Parameter(Mandatory)]
        $Deployments
    )

    try {

        $ResultDeployments = $Deployments | Where-Object {
            $_.SoftwareName -eq $Package.Name
        }

        return @(
            $ResultDeployments |
            Select-Object -ExpandProperty CollectionID -Unique
        ).Count
    }
    catch {

        Write-PCXLog -Message $_.Exception.Message -Level ERROR
        throw
    }
}
