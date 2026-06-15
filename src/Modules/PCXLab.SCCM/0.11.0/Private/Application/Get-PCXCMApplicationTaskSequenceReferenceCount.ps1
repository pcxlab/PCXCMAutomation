function Get-PCXCMApplicationTaskSequenceReferenceCount {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        $Application
    )

    try {

        # Placeholder until Task Sequence parsing module is implemented

        return 0
    }
    catch {

        Write-PCXLog -Message $_.Exception.Message -Level ERROR
        throw
    }
}
