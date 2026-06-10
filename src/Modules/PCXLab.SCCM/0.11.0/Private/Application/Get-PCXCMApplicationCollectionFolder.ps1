function Get-PCXCMApplicationCollectionFolder {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        $Application
    )

    try {

        $CollectionFolder = Get-CMFolder `
            -Name $Application.LocalizedDisplayName `
            -ErrorAction SilentlyContinue |
        Where-Object {
            $_.ObjectTypeName -eq 'SMS_Collection_Device'
        }

        if (@($CollectionFolder).Count -gt 1) {
            throw 'Multiple collection folders found.'
        }

        return $CollectionFolder
    }
    catch {

        Write-PCXLog -Message $_.Exception.Message -Level ERROR
        throw
    }
}