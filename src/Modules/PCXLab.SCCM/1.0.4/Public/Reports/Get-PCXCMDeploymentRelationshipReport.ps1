function Get-PCXCMDeploymentRelationshipReport {

    [CmdletBinding()]
    param()

    begin {
        Write-PCXOperationStart
    }
    process {
        try {
            Ensure-PCXCMConnection

            $Deployments = Get-PCXCMCachedDeployment

            foreach ($Deployment in $Deployments) {

                $CollectionMemberCount = Get-PCXCMDeploymentCollectionMemberCount `
                    -Deployment $Deployment

                [PSCustomObject]@{

                    ApplicationName       = $Deployment.ApplicationName
                    CollectionName        = $Deployment.CollectionName
                    CollectionID          = $Deployment.CollectionID

                    CollectionMemberCount = $CollectionMemberCount

                    DeploymentID          = $Deployment.DeploymentID
                    DeploymentIntent      = $Deployment.DeploymentIntent

                    Enabled               = $Deployment.Enabled

                    NumberTargeted        = $Deployment.NumberTargeted
                    NumberSuccess         = $Deployment.NumberSuccess
                    NumberErrors          = $Deployment.NumberErrors
                    NumberInProgress      = $Deployment.NumberInProgress

                    CreationTime          = $Deployment.CreationTime
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
