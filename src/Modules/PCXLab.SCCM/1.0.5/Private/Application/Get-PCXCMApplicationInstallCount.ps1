function Get-PCXCMApplicationInstallCount {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        $Application
    )

    try {

        # Future enhancement:
        # Populate from App Deployment Asset Details,
        # CMPivot, Inventory, or SQL reporting.

        return $null
    }
    catch {

        Write-PCXLog -Message $_.Exception.Message -Level ERROR
        throw
    }
}
