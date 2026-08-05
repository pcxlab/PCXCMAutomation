function Get-PCXCMCollectionMemberChangeAge {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        $Collection
    )

    try {

        if (-not $Collection.LastMemberChangeTime) {
            return 0
        }

        return [int](
            (New-TimeSpan `
                -Start $Collection.LastMemberChangeTime `
                -End (Get-Date)
            ).TotalDays
        )
    }
    catch {

        Write-PCXLog -Message $_.Exception.Message -Level ERROR
        throw
    }
}
