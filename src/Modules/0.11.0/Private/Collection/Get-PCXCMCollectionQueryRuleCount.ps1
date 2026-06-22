function Get-PCXCMCollectionQueryRuleCount {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        $Collection
    )

    try {

        return @(
            $Collection.CollectionRules |
            Where-Object {
                $_.ObjectClass -eq 'SMS_CollectionRuleQuery'
            }
        ).Count
    }
    catch {

        Write-PCXLog -Message $_.Exception.Message -Level ERROR
        throw
    }
}
