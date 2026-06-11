function Get-PCXCMCollectionIncludeRuleCount {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        $Collection
    )

    try {

        return @(
            $Collection.CollectionRules |
            Where-Object {
                $_.RuleName -eq 'SMS_CollectionRuleIncludeCollection'
            }
        ).Count
    }
    catch {

        Write-PCXLog -Message $_.Exception.Message -Level ERROR
        throw
    }
}