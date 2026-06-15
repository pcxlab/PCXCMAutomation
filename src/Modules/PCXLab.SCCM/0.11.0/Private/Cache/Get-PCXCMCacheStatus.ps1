function Get-PCXCMCacheStatus {

    [CmdletBinding()]
    param(
        [string]$Name
    )

    try {

        $CacheRoot = 'C:\ProgramData\PCXLab\SCCMCache'

        if (-not (Test-Path $CacheRoot)) {
            return
        }

        $Results = Get-ChildItem `
            -Path $CacheRoot `
            -Filter *.metadata.json |
        ForEach-Object {

            $Metadata = Get-Content `
                -Path $_.FullName `
                -Raw |
                ConvertFrom-Json

            $Created = [datetime]::Parse(
                $Metadata.Created
            )

            $AgeHours = [math]::Round(
                (
                    (Get-Date) - $Created
                ).TotalHours,
                2
            )

            [PSCustomObject]@{
                Name         = $Metadata.Name
                ItemCount    = $Metadata.ItemCount
                Created      = $Created
                AgeHours     = $AgeHours
                ExpiresHours = $Metadata.ExpiresHours
                Expired      = (
                    $AgeHours -ge
                    $Metadata.ExpiresHours
                )
            }
        }

        if ($Name) {

            return $Results |
                Where-Object {
                    $_.Name -eq $Name
                } |
                Select-Object -First 1
        }

        return $Results
    }
    catch {

        Write-PCXLog `
            -Message $_.Exception.Message `
            -Level ERROR

        throw
    }
}
