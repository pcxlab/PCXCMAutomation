function Get-PCXCMApplicationCollectionObjects {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        $Application,

        [Parameter(Mandatory)]
        $Collections
    )

    try {

        return @(
            $Collections | Where-Object {
                $_.Name -like "$($Application.LocalizedDisplayName)*"
            }
        )
    }
    catch {

        Write-PCXLog -Message $_.Exception.Message -Level ERROR
        throw
    }
}
