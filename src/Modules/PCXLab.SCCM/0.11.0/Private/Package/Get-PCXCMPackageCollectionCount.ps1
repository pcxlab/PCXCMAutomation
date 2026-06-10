function Get-PCXCMPackageCollectionCount {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        $Package
    )

    try {

        $Deployments = Get-CMDeployment `
            -SoftwareName $Package.Name `
            -ErrorAction SilentlyContinue

        return @(
            $Deployments |
            Select-Object -ExpandProperty CollectionID -Unique
        ).Count
    }
    catch {

        Write-PCXLog -Message $_.Exception.Message -Level ERROR
        throw
    }
}