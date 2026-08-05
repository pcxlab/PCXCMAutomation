function Get-PCXCMTaskSequenceDeploymentCount {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        $TaskSequence,

        [Parameter(Mandatory)]
        $TaskSequenceDeployments
    )

    try {

        $ResultDeployments = $TaskSequenceDeployments |
            Where-Object {
                $_.PackageID -eq $TaskSequence.PackageID
            }

        return @($ResultDeployments).Count
    }
    catch {

        Write-PCXLog `
            -Message $_.Exception.Message `
            -Level ERROR

        throw
    }
}
