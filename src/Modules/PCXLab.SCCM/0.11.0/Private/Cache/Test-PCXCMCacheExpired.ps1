function Test-PCXCMCacheExpired {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Name
    )

    try {
        $CacheRoot = 'C:\ProgramData\PCXLab\SCCMCache'

        $MetadataFile = Join-Path $CacheRoot "$Name.metadata.json"

        if (-not (Test-Path $MetadataFile)) {
            return $true
        }

        $Metadata = Get-Content -Path $MetadataFile -Raw | ConvertFrom-Json

        $Created = [datetime]::Parse($Metadata.Created)
        $AgeHours = ((Get-Date) - $Created).TotalHours
        return ($AgeHours -ge $Metadata.ExpiresHours)
    }
    catch {
        Write-PCXLog -Message $_.Exception.Message -Level ERROR
        throw
    }
}
