function Get-PCXCMApplicationDependencyCount {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        $Application
    )

    try {

        if ($Application.NumberOfDependentDTs -ne $null) {
            return [int]$Application.NumberOfDependentDTs
        }

        return 0
    }
    catch {

        Write-PCXLog -Message $_.Exception.Message -Level ERROR
        throw
    }
}
