function Get-PCXCMTaskSequenceEnabledStatus {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        $TaskSequence
    )

    try {

        return [bool]$TaskSequence.TsEnabled
    }
    catch {

        Write-PCXLog -Message $_.Exception.Message -Level ERROR
        throw
    }
}
