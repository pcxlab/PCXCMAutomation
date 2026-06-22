$Package = Get-CMPackage |
    Select-Object -First 1

Measure-Command {

    Get-PCXCMPackageDeploymentCount `
        -Package $Package

} | Select-Object TotalSeconds

Measure-Command {

    Get-PCXCMPackageCollectionCount `
        -Package $Package

} | Select-Object TotalSeconds

Measure-Command {

    Get-PCXCMPackageLastModifiedAge `
        -Package $Package

} | Select-Object TotalSeconds

Measure-Command {

    Get-PCXCMPackageDistributionStatus `
        -Package $Package

} | Select-Object TotalSeconds
