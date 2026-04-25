function New-PCXCMDeployment{
     param(
        [parameter(Mandatory=$true, Position=0)]
        [string]$Packagename,

        [parameter(Mandatory=$true, Position=1)]
        [string]$Collectionname,

        [parameter(Mandatory=$false, Position=2)] 
        [string]$Comment,

        [parameter(Mandatory=$true, Position=3)] 
        [string]$Programname,

        [parameter(Mandatory=$true, Position=4)]
        [string]$deploypurpose,

        [parameter(Mandatory=$false, Position=5)] 
        $schedule,

        [parameter(Mandatory=$false, Position=6)] 
        [DateTime]$DeadlineTime,

        [parameter(Mandatory=$false, Position=7)] 
        [array]$NewScheduleDeadline
        
     )
     # Date Time calculation 
      $DeadlineTime = (Get-Date -Hour 23 -Minute 0 -Second 0).AddDays(15)
      $NewScheduleDeadline = New-CMSchedule  -Start $DeadlineTime -Nonrecurring

      # Command
      New-CMPackageDeployment -StandardProgram -PackageName $Packagename -CollectionName $Collectionname -DeployPurpose $deploypurpose -ProgramName $Programname  -Schedule $NewScheduleDeadline 
}

<#
MS-Document : 
https://learn.microsoft.com/en-us/powershell/module/configurationmanager/new-cmpackagedeployment?view=sccm-ps

Direct Command :
New-CMPackageDeployment -StandardProgram -PackageName $Packagename -CollectionName $Collectionname -DeployPurpose Required -ProgramName $Programname  -Schedule $NewScheduleDeadline

Usage examples::::::::::::::::::
New-PCXCMDeployment -Packagename "PKG_7zip_2.0.0" -Collectionname "PKG_7zip_2.0.0_01[Available]" -Programname "AvailableProgram" -Comment "PKG_7Zip Program" -deploypurpose "Available"                    
New-PCXCMDeployment -packagename "PKG_7zip_2.0.0" -collectionname "PKG_7zip_2.0.0_01[Install]" -programname "InstallProgram" -comment "PKG_7Zip Program" -deploypurpose "Required " -schedule "NewScheduleDeadline"
New-PCXCMDeployment -packagename "PKG_7zip_2.0.0" -collectionname "PKG_7zip_2.0.0_01[UnInstall]" -programname "UninstallProgram" -comment "PKG_7Zip Program"  -deploypurpose "Required" -schedule "NewScheduleDeadline"
#>


      