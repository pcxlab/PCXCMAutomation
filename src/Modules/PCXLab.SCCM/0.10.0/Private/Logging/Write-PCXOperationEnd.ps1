function Write-PCXOperationEnd {

    [CmdletBinding()]
    param(

        [ValidateSet("Success","Failed")]
        [string]$Status = "Success"
    )

    if (
        $Global:PCXOperationStack -and
        $Global:PCXOperationStack.Count -gt 0
    ) {

        $Operation = $Global:PCXOperationStack.Peek()

        Write-PCXLog "COMPLETED ($($Status.ToUpper())) - $($Global:PCXLogConfiguration.Website)"

        [void]$Global:PCXOperationStack.Pop()
    }
    else {

        Write-PCXLog "COMPLETED ($($Status.ToUpper())) - Unknown Operation - $($Global:PCXLogConfiguration.Website)"
    }
}