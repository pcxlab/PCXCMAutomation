function Get-PCXCMCollectionCleanupReport {

    [CmdletBinding()]
    param(
        [string]$Name = '*'
    )

    begin {

        Write-PCXOperationStart
    }

    process {

        try {

            $Deployments = Get-PCXCMCachedDeployment

            $Collections = Get-PCXCMCachedCollection | Where-Object {
                $_.Name -like $Name
            }

            foreach ($Collection in $Collections) {

                $MemberCount = Get-PCXCMCollectionMemberCount `
                    -Collection $Collection

                $DeploymentCount = Get-PCXCMCollectionDeploymentCount `
                    -Collection $Collection `
                    -Deployments $Deployments

                $IncludeCollectionRuleCount = Get-PCXCMCollectionIncludeRuleCount `
                    -Collection $Collection

                $ExcludeCollectionRuleCount = Get-PCXCMCollectionExcludeRuleCount `
                    -Collection $Collection

                $QueryRuleCount = Get-PCXCMCollectionQueryRuleCount `
                    -Collection $Collection

                $DirectRuleCount = Get-PCXCMCollectionDirectRuleCount `
                    -Collection $Collection

                $RuleCount = $QueryRuleCount + $DirectRuleCount + $IncludeCollectionRuleCount + $ExcludeCollectionRuleCount

                $LimitingCollection = Get-PCXCMCollectionLimitingCollection `
                    -Collection $Collection

                $LastRefreshTime = Get-PCXCMCollectionLastRefreshTime `
                    -Collection $Collection

                $MemberChangeAgeDays = Get-PCXCMCollectionMemberChangeAge `
                    -Collection $Collection

                $CollectionAgeDays = Get-PCXCMCollectionAge `
                    -Collection $Collection

                $RefreshType = Get-PCXCMCollectionRefreshType `
                    -Collection $Collection

                $CleanupScore = Get-PCXCMCollectionCleanupScore `
                    -MemberCount $MemberCount `
                    -DeploymentCount $DeploymentCount

                $Recommendation = Get-PCXCMCollectionCleanupRecommendation `
                    -MemberCount $MemberCount `
                    -DeploymentCount $DeploymentCount

                $Risk = Get-PCXCMCleanupRisk `
                    -Recommendation $Recommendation

                [PSCustomObject]@{
                    CollectionName             = $Collection.Name
                    CollectionID               = $Collection.CollectionID
                    CollectionType             = $Collection.CollectionType

                    MemberCount                = $MemberCount
                    DeploymentCount            = $DeploymentCount

                    IncludeCollectionRuleCount = $IncludeCollectionRuleCount

                    ExcludeCollectionRuleCount = $ExcludeCollectionRuleCount

                    QueryRuleCount             = $QueryRuleCount
                    DirectRuleCount            = $DirectRuleCount
                    RuleCount                  = $RuleCount

                    LimitingCollection         = $LimitingCollection

                    RefreshType                = $RefreshType
                    LastRefreshTime            = $LastRefreshTime
                    CollectionAgeDays          = $CollectionAgeDays
                    MemberChangeAgeDays        = $MemberChangeAgeDays

                    CleanupScore               = $CleanupScore
                    Risk                       = $Risk
                    Recommendation             = $Recommendation
                }
            }
        }
        catch {

            Write-PCXLog -Message $_.Exception.Message -Level ERROR
            throw
        }
    }

    end {

        Write-PCXOperationEnd
    }
}
