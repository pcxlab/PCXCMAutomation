function Get-PCXCMApplicationDeploymentObjects {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        $Application
    )
    try {
        return @(Get-PCXCMCachedDeployment | Where-Object {
                $_.SoftwareName -eq $Application.LocalizedDisplayName
            })
    }
    catch {
        Write-PCXLog -Message $_.Exception.Message -Level ERROR
        throw
    }
}
