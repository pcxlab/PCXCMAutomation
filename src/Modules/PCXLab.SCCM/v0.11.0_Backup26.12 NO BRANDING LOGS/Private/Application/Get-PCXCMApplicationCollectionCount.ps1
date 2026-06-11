function Get-PCXCMApplicationCollectionCount {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        $Application
    )

    try {

        $Collections = Get-CMDeviceCollection `
            -Name "$($Application.LocalizedDisplayName)*" `
            -ErrorAction SilentlyContinue

        return @($Collections).Count
    }
    catch {

        Write-PCXLog -Message $_.Exception.Message -Level ERROR
        throw
    }
}