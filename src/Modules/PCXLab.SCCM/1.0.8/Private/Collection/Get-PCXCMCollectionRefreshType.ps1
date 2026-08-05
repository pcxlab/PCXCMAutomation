function Get-PCXCMCollectionRefreshType {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        $Collection
    )

    try {

        switch ($Collection.RefreshType) {

            1 { return 'Manual' }

            2 { return 'Periodic' }

            4 { return 'Incremental' }

            6 { return 'Periodic + Incremental' }

            default { return 'Unknown' }
        }
    }
    catch {

        Write-PCXLog -Message $_.Exception.Message -Level ERROR
        throw
    }
}
