Import-Module PCXLab.SCCM -Force

Ensure-PCXCMConnection

$Application = Get-CMApplication `
    -Name 'APP Google Chrome 145.0.7632.46' `
    -Fast

$Result = Get-PCXCMApplicationDeploymentCount `
    -Application $Application

Write-Host "Application : $($Application.LocalizedDisplayName)"
Write-Host "Deployments : $Result"
