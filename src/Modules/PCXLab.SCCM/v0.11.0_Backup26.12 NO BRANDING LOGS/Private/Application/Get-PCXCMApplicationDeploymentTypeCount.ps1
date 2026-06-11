function Get-PCXCMApplicationDeploymentTypeCount {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        $Application
    )

    try {

        return [int]$Application.NumberOfDeploymentTypes
    }
    catch {

        Write-PCXLog -Message $_.Exception.Message -Level ERROR
        throw
    }
}