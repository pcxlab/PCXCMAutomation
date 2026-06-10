function Get-PCXCMPackageDeploymentCount {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        $Package
    )

    try {

        $Deployments = Get-CMDeployment `
            -SoftwareName $Package.Name `
            -ErrorAction SilentlyContinue

        return @($Deployments).Count
    }
    catch {

        Write-PCXLog -Message $_.Exception.Message -Level ERROR
        throw
    }
}