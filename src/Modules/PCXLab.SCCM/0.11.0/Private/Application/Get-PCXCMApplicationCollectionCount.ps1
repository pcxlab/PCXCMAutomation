function Get-PCXCMApplicationCollectionCount {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        $Application,

        [Parameter(Mandatory)]
        $Collections
    )

    try {

        $ResultCollections = $Collections | Where-Object {
            $_.Name -like "$($Application.LocalizedDisplayName)*"
        }

        return @($ResultCollections).Count
    }
    catch {

        Write-PCXLog -Message $_.Exception.Message -Level ERROR
        throw
    }
}
