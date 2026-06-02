function Get-PCXOperationName {

    [CmdletBinding()]
    param()

    $Stack = Get-PSCallStack

    if ($Stack.Count -gt 2) {
        $FunctionName = $Stack[2].Command
    }
    else {
        $FunctionName = $Stack[0].Command
    }

    if (
        $Global:PCXLogConfiguration.UseFriendlyNames -and
        $Global:PCXOperationNames.ContainsKey($FunctionName)
    ) {
        return $Global:PCXOperationNames[$FunctionName]
    }

    return $FunctionName
}