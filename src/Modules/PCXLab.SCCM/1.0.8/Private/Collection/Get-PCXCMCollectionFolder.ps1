function Get-PCXCMCollectionFolder {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Name
    )

    try {

        $CollectionFolder = Get-CMFolder -Name $Name -ErrorAction SilentlyContinue |
            Where-Object ObjectTypeName -eq 'SMS_Collection_Device'

        if (@($CollectionFolder).Count -gt 1) {
            throw "Multiple collection folders found: $Name"
        }

        return $CollectionFolder | Select-Object -First 1
    }
    catch {

        Write-PCXLog -Message $_.Exception.Message -Level ERROR
        throw
    }
}
