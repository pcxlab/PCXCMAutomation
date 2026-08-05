function Get-PCXCMCollectionMemberCount {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        $Collection
    )

    try {

        if ($null -ne $Collection.MemberCount) {
            return [int]$Collection.MemberCount
        }

        return 0
    }
    catch {

        Write-PCXLog -Message $_.Exception.Message -Level ERROR
        throw
    }
}
