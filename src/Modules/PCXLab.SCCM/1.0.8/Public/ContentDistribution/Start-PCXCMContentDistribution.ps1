function Start-PCXCMContentDistribution {

    [CmdletBinding(DefaultParameterSetName = 'Application')]
    param(

        [Parameter(Mandatory, ParameterSetName = 'Application')]
        [string]$ApplicationName,

        [Parameter(Mandatory, ParameterSetName = 'Package')]
        [string]$PackageName,

        [string[]]$DistributionPointGroups,

        [string[]]$DistributionPoints
    )

    begin {
        Write-PCXOperationStart
    }

    process {
        try {

            if (-not $DistributionPointGroups -and -not $DistributionPoints) {
                throw "At least one Distribution Point Group or Distribution Point must be specified."

            }

            Ensure-PCXCMConnection

            switch ($PSCmdlet.ParameterSetName) {

                'Application' {
                    Write-PCXLog "Content Type : Application"
                    Write-PCXLog "Application : $ApplicationName"
                    
                    foreach ($DP in $DistributionPoints) {

                        Write-PCXLog "DP : $DP"

                        $null = Start-CMContentDistribution `
                            -ApplicationName $ApplicationName `
                            -DistributionPointName $DP

                        Write-PCXLog "Application distribution initiated to DP [$DP]"
                    }

                    foreach ($DPGroup in $DistributionPointGroups) {

                        Write-PCXLog "DP Group : $DPGroup"

                        $null = Start-CMContentDistribution `
                            -ApplicationName $ApplicationName `
                            -DistributionPointGroupName $DPGroup

                        Write-PCXLog "Application distribution initiated to DP Group [$DPGroup]"
                    }

                    return [PSCustomObject]@{
                        Success                 = $true
                        ContentType             = 'Application'
                        Name                    = $ApplicationName
                        DistributionPointGroups = $DistributionPointGroups
                        DistributionPoints      = $DistributionPoints
                    }
                }

                'Package' {
                    Write-PCXLog "Content Type : Package"
                    Write-PCXLog "Package : $PackageName"
                    
                    foreach ($DP in $DistributionPoints) {

                        Write-PCXLog "DP : $DP"

                        $null = Start-CMContentDistribution `
                            -PackageName $PackageName `
                            -DistributionPointName $DP

                        Write-PCXLog "Package distribution initiated to DP [$DP]"
                    }

                    foreach ($DPGroup in $DistributionPointGroups) {

                        Write-PCXLog "DP Group : $DPGroup"

                        $null = Start-CMContentDistribution `
                            -PackageName $PackageName `
                            -DistributionPointGroupName $DPGroup

                        Write-PCXLog "Package distribution initiated to DP Group [$DPGroup]"
                    }

                    return [PSCustomObject]@{
                        Success                 = $true
                        ContentType             = 'Package'
                        Name                    = $PackageName
                        DistributionPointGroups = $DistributionPointGroups
                        DistributionPoints      = $DistributionPoints
                    }
                }
            }
        }
        catch {
            Write-PCXLog -Message "Content distribution failed. $($_.Exception.Message)" -Level ERROR
            throw
        }
    }
    end {
        Write-PCXOperationEnd -Status Success
    }
}


