Import-Module PCXLab.SCCM -Force

Connect-PCXCMSite

$Application = Get-CMApplication `
    -Name 'APP Google Chrome 145.0.7632.46' `
    -Fast

$Result = Get-PCXCMApplicationCollectionCount `
    -Application $Application

Write-Host "Application : $($Application.LocalizedDisplayName)"
Write-Host "Collections : $Result"
