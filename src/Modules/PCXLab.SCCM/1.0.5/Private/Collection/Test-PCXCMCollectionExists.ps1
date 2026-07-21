function Test-PCXCMCollectionExists {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$CollectionName
    )
    try {
        return $null -ne (Get-CMDeviceCollection -Name $CollectionName -ErrorAction SilentlyContinue)
    }
    catch {
        Write-PCXLog -Message $_.Exception.Message -Level ERROR
        throw
    }
}