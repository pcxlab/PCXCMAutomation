function Get-PCXCMCollectionAge {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        $Collection
    )

    try {

        if (-not $Collection.LastChangeTime) {
            return 0
        }

        return [int](
            (New-TimeSpan `
                -Start $Collection.LastChangeTime `
                -End (Get-Date)
            ).TotalDays
        )
    }
    catch {

        Write-PCXLog -Message $_.Exception.Message -Level ERROR
        throw
    }
}
