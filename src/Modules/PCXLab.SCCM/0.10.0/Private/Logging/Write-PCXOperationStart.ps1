function Write-PCXOperationStart {

    [CmdletBinding()]
    param()

    $Operation = Get-PCXOperationName

    $Global:PCXOperationStack.Push($Operation)

    Write-PCXLog "$($Global:PCXLogConfiguration.StartText) - $($Global:PCXLogConfiguration.FrameworkName)"
}