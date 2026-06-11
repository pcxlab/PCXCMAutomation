function Get-PCXCMApplicationSupersedenceCount {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        $Application
    )

    try {

        if ($Application.IsSuperseded -or $Application.IsSuperseding) {
            return 1
        }

        return 0
    }
    catch {

        Write-PCXLog -Message $_.Exception.Message -Level ERROR
        throw
    }
}