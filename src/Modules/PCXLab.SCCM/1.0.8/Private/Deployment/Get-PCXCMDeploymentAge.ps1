function Get-PCXCMDeploymentAge {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        $Deployment
    )

    try {

        if (-not $Deployment.CreationTime) {
            return 0
        }

        return [math]::Round(
            ((Get-Date) - $Deployment.CreationTime).TotalDays,
            0
        )
    }
    catch {

        Write-PCXLog -Message $_.Exception.Message -Level ERROR
        throw
    }
}
