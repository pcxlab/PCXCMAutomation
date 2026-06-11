function Get-PCXCMTaskSequenceCleanupReport {

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

            $TaskSequences = Get-CMTaskSequence -Name $Name -Fast

            foreach ($TaskSequence in $TaskSequences) {

                $DeploymentCount = Get-PCXCMTaskSequenceDeploymentCount `
                    -TaskSequence $TaskSequence

                $ReferenceCount = Get-PCXCMTaskSequenceReferenceCount `
                    -TaskSequence $TaskSequence

                $Enabled = Get-PCXCMTaskSequenceEnabledStatus `
                    -TaskSequence $TaskSequence

                $TaskSequenceAgeDays = Get-PCXCMTaskSequenceAge `
                    -TaskSequence $TaskSequence

                $CleanupScore = Get-PCXCMTaskSequenceCleanupScore `
                    -DeploymentCount $DeploymentCount `
                    -Enabled $Enabled

                $Recommendation = Get-PCXCMTaskSequenceCleanupRecommendation `
                    -DeploymentCount $DeploymentCount `
                    -Enabled $Enabled

                $Risk = Get-PCXCMCleanupRisk `
                    -Recommendation $Recommendation

                [PSCustomObject]@{
                    TaskSequenceName  = $TaskSequence.Name
                    PackageID         = $TaskSequence.PackageID

                    DeploymentCount   = $DeploymentCount
                    ReferenceCount    = $ReferenceCount

                    Enabled           = $Enabled

                    AgeDays           = $TaskSequenceAgeDays

                    CleanupScore      = $CleanupScore
                    Risk              = $Risk
                    Recommendation    = $Recommendation
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