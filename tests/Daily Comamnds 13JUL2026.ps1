# Test push
cls
C:
Remove-Module PCXLab.SCCM -Force
Remove-Module PCXLab.SCCM
Clear-Host
Import-Module .\src\Modules\PCXLab.SCCM
#Import-Module .\src\Modules\PCXLab.SCCM -Force

get-module -Name PCXLab.SCCM
Get-Command -Module PCXLab.SCCM

Get-ChildItem .\src\Modules\PCXLab.SCCM\1.0.2 -Recurse -Include *.ps1 |
Select-String "DefaultLimitingCollection"



Get-ChildItem C:\Projects\PCXLABCMAutomation -Recurse -Include *.ps1, *.psm1, *.psd1 |
Select-String -Pattern 'Perfect'


Get-ChildItem C:\Projects\PCXLABCMAutomation -Recurse -Include *.ps1, *.psm1, *.psd1 |
Select-String -Pattern 'LiteralPath'

Create-PCXCMPackage -Path "\\192.168.25.214\Package_Source\Applications\Igor Pavlov\7zip\7zip 27.121.3" -DistributionPointGroups "All Mangalore DPs" 


     
Get-CMPackage -Name "PKG Igor Pavlov 7zip 27.121.3" -Fast


Get-CMPackage -Name "PKG Igor Pavlov 7zip 27.121.3" -Fast |
Format-Table Name, PackageID


Get-Command Set-CMScriptDeploymentType -Syntax

Get-Command Set-CMMsiDeploymentType -Syntax

Test-Path "\\192.168.25.214\Package_Source\Icons\"

(Get-Command Add-PCXCMPackageProgram).Source

(Get-Command Add-PCXCMPackageProgram).Module.Version

(Get-Command Add-PCXCMPackageProgram).Definition

(Get-Command Add-PCXCMPackageProgram).Definition


(Get-Command New-PCXCMPackageProgramNames).Definition


$ProgramNames = New-PCXCMPackageProgramNames `
    -Company "Google" `
    -Product "Chrome Enterprise" `
    -Version "155.0.7632.03"

$ProgramNames | Format-List *


Get-Command New-PCXCMProgramName


If the output is too long, run these one at a time:

Get-Content "C:\Projects\PCXLABCMAutomation\src\Modules\PCXLab.SCCM\1.0.5\Public\Connection\Connect-PCXCMSite.ps1"
Get-Content "C:\Projects\PCXLABCMAutomation\src\Modules\PCXLab.SCCM\1.0.5\Public\Connection\Ensure-PCXCMConnection.ps1"
Get-Content "C:\Projects\PCXLABCMAutomation\src\Modules\PCXLab.SCCM\1.0.5\Private\Connection\Test-PCXCMConnection.ps1"
Get-Content "C:\Projects\PCXLABCMAutomation\src\Modules\PCXLab.SCCM\1.0.5\Private\Connection\Get-PCXCMSiteCode.ps1"
Get-Content "C:\Projects\PCXLABCMAutomation\src\Modules\PCXLab.SCCM\1.0.5\Private\Connection\Get-PCXCMProviderMachineName.ps1"

Onc


Please send me these two files next
Get-Content "C:\Projects\PCXLABCMAutomation\src\Modules\PCXLab.SCCM\1.0.5\Private\Core\Initialize-PCXCMEnvironment.ps1"
Get-Content "C:\Projects\PCXLABCMAutomation\src\Modules\PCXLab.SCCM\1.0.5\Private\Core\Get-PCXCMSetting.ps1"

Once I ha

cls

Get-Content "C:\Projects\PCXLABCMAutomation\src\Modules\PCXLab.SCCM\1.0.5\Public\Connection\Initialize-PCXCMEnvironment.ps1"


coding style:

Get-Content "C:\Projects\PCXLABCMAutomation\src\Modules\PCXLab.SCCM\1.0.5\Public\Connection\Connect-PCXCMSite.ps1"
Get-Content "C:\Projects\PCXLABCMAutomation\src\Modules\PCXLab.SCCM\1.0.5\Public\Connection\Ensure-PCXCMConnection.ps1"
Get-Content "C:\Projects\PCXLABCMAutomation\src\Modules\PCXLab.SCCM\1.0.5\Private\Connection\Test-PCXCMConnection.ps1"
Get-Content "C:\Projects\PCXLABCMAutomation\src\Modules\PCXLab.SCCM\1.0.5\Private\Connection\Get-PCXCMSiteCode.ps1"
Get-Content "C:\Projects\PCXLABCMAutomation\src\Modules\PCXLab.SCCM\1.0.5\Private\Connection\Get-PCXCMProviderMachineName.ps1"

O