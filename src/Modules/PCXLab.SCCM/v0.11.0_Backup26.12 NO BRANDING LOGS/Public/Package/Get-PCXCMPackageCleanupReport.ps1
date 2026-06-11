function Get-PCXCMPackageCleanupReport {

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

            $Packages = Get-CMPackage -Name $Name -Fast

            foreach ($Package in $Packages) {
                
                # 1. Core Package Information
                $PackageSize = Get-PCXCMPackageSize `
                    -Package $Package

                $SourcePathStatus = Get-PCXCMPackageSourcePathStatus `
                    -SourcePath $Package.PkgSourcePath

                $SourceVersion = Get-PCXCMPackageSourceVersion `
                    -Package $Package

                # 2. Usage Metrics
                $DeploymentCount = Get-PCXCMPackageDeploymentCount `
                    -Package $Package

                $CollectionCount = Get-PCXCMPackageCollectionCount `
                    -Package $Package

                $ProgramCount = Get-PCXCMPackageProgramCount `
                    -Package $Package    

                # 3. Age Metrics
                $PackageAgeDays = Get-PCXCMPackageAge `
                    -Package $Package

                $LastModifiedAgeDays = Get-PCXCMPackageLastModifiedAge `
                    -Package $Package

                # 4. Operational Status
                $DistributionStatus = Get-PCXCMPackageDistributionStatus `
                    -Package $Package

                # 5. Analytics
                $Recommendation = Get-PCXCMPackageCleanupRecommendation `
                    -DeploymentCount $DeploymentCount `
                    -CollectionCount $CollectionCount `
                    -LastModifiedAgeDays $LastModifiedAgeDays

                $Risk = Get-PCXCMCleanupRisk `
                    -Recommendation $Recommendation

                [PSCustomObject]@{
                    PackageName         = $Package.Name
                    PackageID           = $Package.PackageID
                    Manufacturer        = $Package.Manufacturer
                    Version             = $Package.Version

                    SourcePath          = $Package.PkgSourcePath
                    SourcePathStatus    = $SourcePathStatus
                    SourceVersion       = $SourceVersion
                    PackageSize         = $PackageSize

                    DeploymentCount     = $DeploymentCount
                    CollectionCount     = $CollectionCount
                    ProgramCount        = $ProgramCount

                    PackageAgeDays      = $PackageAgeDays
                    LastModifiedAgeDays = $LastModifiedAgeDays

                    DistributionStatus  = $DistributionStatus

                    Risk                = $Risk
                    Recommendation      = $Recommendation
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