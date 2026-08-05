function Get-PCXCMPackageDeploymentCount {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        $Package,

        [Parameter(Mandatory)]
        $Deployments
    )

    try {

        $ResultDeployments = $Deployments | Where-Object {
            $_.PackageID -eq $Package.PackageID
        }

        return @($ResultDeployments).Count
    }
    catch {

        Write-PCXLog -Message $_.Exception.Message -Level ERROR
        throw
    }
}
