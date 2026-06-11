function Get-PCXCMCollectionDirectRuleCount {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        $Collection
    )

    try {

        return @(
            $Collection.CollectionRules |
            Where-Object {
                $_.ObjectClass -eq 'SMS_CollectionRuleDirect'
            }
        ).Count
    }
    catch {

        Write-PCXLog -Message $_.Exception.Message -Level ERROR
        throw
    }
}