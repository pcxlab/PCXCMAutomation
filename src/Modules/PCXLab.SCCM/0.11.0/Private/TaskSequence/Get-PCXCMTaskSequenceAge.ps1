function Get-PCXCMTaskSequenceAge {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        $TaskSequence
    )

    try {

        if (-not $TaskSequence.SourceDate) {
            return 0
        }

        return (
            New-TimeSpan `
                -Start $TaskSequence.SourceDate `
                -End (Get-Date)
        ).Days
    }
    catch {

        Write-PCXLog -Message $_.Exception.Message -Level ERROR
        throw
    }
}