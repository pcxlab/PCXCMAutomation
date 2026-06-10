function Get-PCXCMApplicationDeployedStatus {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        $Application
    )

    try {

        return [bool]$Application.IsDeployed
    }
    catch {

        Write-PCXLog -Message $_.Exception.Message -Level ERROR
        throw
    }
}