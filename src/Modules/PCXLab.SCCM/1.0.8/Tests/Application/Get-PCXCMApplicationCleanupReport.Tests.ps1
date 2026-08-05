$Report = Get-PCXCMApplicationCleanupReport `
    -Name 'APP Google Chrome 145.0.7632.46'

$Report.ApplicationName
$Report.DeploymentCount
$Report.CollectionCount
$Report.Recommendation
