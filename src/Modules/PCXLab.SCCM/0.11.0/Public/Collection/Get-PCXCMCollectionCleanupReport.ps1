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

            Ensure-PCXCMConnection

            $Collections = Get-CMDeviceCollection `
                -Name $Name

            foreach ($Collection in $Collections) {

                $DeploymentCount = Get-PCXCMCollectionDeploymentCount `
                    -Collection $Collection

                $MemberCount = Get-PCXCMCollectionMemberCount `
                    -Collection $Collection

                $LastRefreshTime = Get-PCXCMCollectionLastRefreshTime `
                    -Collection $Collection

                $LimitingCollection = Get-PCXCMCollectionLimitingCollection `
                    -Collection $Collection

                [PSCustomObject]@{
                    CollectionName      = $Collection.Name
                    CollectionID        = $Collection.CollectionID
                    CollectionType      = $Collection.CollectionType

                    MemberCount         = $MemberCount
                    DeploymentCount     = $DeploymentCount

                    LimitingCollection  = $LimitingCollection
                    LastRefreshTime     = $LastRefreshTime
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