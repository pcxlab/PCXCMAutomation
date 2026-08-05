function Save-PCXCMCache {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Name,

        [Parameter(Mandatory)]
        $Data,

        [int]$ExpiresHours = 24
    )

    try {
        $CacheRoot = Initialize-PCXCMCacheFolder
        $CacheFile = Join-Path $CacheRoot "$Name.clixml"
        $MetadataFile = Join-Path $CacheRoot "$Name.metadata.json"
        Export-Clixml -Path $CacheFile -InputObject $Data -Force

        $Metadata = [PSCustomObject]@{
            Name         = $Name
            Created      = (Get-Date).ToString('o')
            ItemCount    = if ($null -eq $Data) { 0 } else { $Data.Count };
            ExpiresHours = $ExpiresHours
        }

        $Metadata | ConvertTo-Json | Set-Content $MetadataFile
        Write-PCXLog -Message "Saved cache: $Name ($(@($Data).Count) items)"
    }
    catch {
        Write-PCXLog -Message $_.Exception.Message -Level ERROR
        throw
    }
}
