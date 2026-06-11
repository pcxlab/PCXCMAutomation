function Get-PCXCMApplicationDeploymentObjects {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        $Application
    )

    try {

        return @(Get-CMApplicationDeployment `
            -Name $Application.LocalizedDisplayName `
            -ErrorAction SilentlyContinue)
    }
    catch {

        Write-PCXLog -Message $_.Exception.Message -Level ERROR
        throw
    }
}