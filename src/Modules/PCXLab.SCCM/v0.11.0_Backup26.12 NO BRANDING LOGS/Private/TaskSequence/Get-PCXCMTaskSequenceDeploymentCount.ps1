function Get-PCXCMTaskSequenceDeploymentCount {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        $TaskSequence
    )

    try {

        return @(
            Get-CMTaskSequenceDeployment `
                -TaskSequenceName $TaskSequence.Name `
                -Fast `
                -ErrorAction SilentlyContinue
        ).Count
    }
    catch {

        Write-PCXLog -Message $_.Exception.Message -Level ERROR
        throw
    }
}