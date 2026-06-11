function Get-PCXCMApplicationCollectionObjects {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        $Application
    )

    try {

        return @(Get-CMDeviceCollection `
            -Name "$($Application.LocalizedDisplayName)*" `
            -ErrorAction SilentlyContinue)
    }
    catch {

        Write-PCXLog -Message $_.Exception.Message -Level ERROR
        throw
    }
}