function Get-PCXCMCollectionIncludeExcludeCount {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        $Collection
    )

    try {

        return $Collection.IncludeExcludeCollectionsCount
    }
    catch {

        Write-PCXLog -Message $_.Exception.Message -Level ERROR
        throw
    }
}