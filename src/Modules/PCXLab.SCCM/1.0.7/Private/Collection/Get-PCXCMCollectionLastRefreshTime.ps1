function Get-PCXCMCollectionLastRefreshTime {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        $Collection
    )

    try {

        return $Collection.LastRefreshTime
    }
    catch {

        Write-PCXLog -Message $_.Exception.Message -Level ERROR
        throw
    }
}
