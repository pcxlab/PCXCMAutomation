function Start-PCXCMContentDistribution {

    [CmdletBinding(DefaultParameterSetName = 'Application')]
    param(

        [Parameter(Mandatory, ParameterSetName = 'Application')]
        [string]$ApplicationName,

        [Parameter(Mandatory, ParameterSetName = 'Package')]
        [string]$PackageName,

        [Parameter()]
        [string]$DistributionPointGroupName = "All Mangalore DPs"
    )

    begin {
        Write-PCXOperationStart
    }

    process {
        try {
            switch ($PSCmdlet.ParameterSetName) {

                'Application' {
                    Write-PCXLog "Content Type : Application"
                    Write-PCXLog "Application : $ApplicationName"
                    Write-PCXLog "DP Group : $DistributionPointGroupName"

                    $null = Start-CMContentDistribution -ApplicationName $ApplicationName -DistributionPointGroupName $DistributionPointGroupName

                    Write-PCXLog "Application content distribution initiated"

                    return [PSCustomObject]@{
                        Success                    = $true
                        ContentType                = 'Application'
                        Name                       = $ApplicationName
                        DistributionPointGroupName = $DistributionPointGroupName
                    }
                }

                'Package' {
                    Write-PCXLog "Content Type : Package"
                    Write-PCXLog "Package : $PackageName"
                    Write-PCXLog "DP Group : $DistributionPointGroupName"

                    $null = Start-CMContentDistribution -PackageName $PackageName -DistributionPointGroupName $DistributionPointGroupName

                    Write-PCXLog "Package content distribution initiated"
                    
                    return [PSCustomObject]@{
                        Success                    = $true
                        ContentType                = 'Package'
                        Name                       = $PackageName
                        DistributionPointGroupName = $DistributionPointGroupName
                    }
                }
            }
        }
        catch {
            Write-PCXLog "Content distribution failed. $($_.Exception.Message)" "ERROR"
            throw
        }
    }
    end {
        Write-PCXOperationEnd -Status Success
    }
}

