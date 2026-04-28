function New-PCXCMPackage{
param (
        [parameter(Mandatory=$true, Position=0)] 
        [string]$Packagename,

        [parameter(Mandatory=$true, Position=1)] 
        [string]$Company,

        [parameter(Mandatory=$true, Position=2)] 
        [string]$Version,

        [parameter(Mandatory=$false, Position=3)]
        [string]$Language = "EN-US",

        [parameter(Mandatory=$true, Position=4)]  
        [string]$Path
     )

     begin{
        Write-Host "Welcome to PCXLab automation" -ForegroundColor Yellow

     }
     process{
        try {
            # assing packag object to variable

            $Package = Get-CMPackage -Name $Packagename

            # If condition to check and proceed with packae creation
            if ($Package -ne $null) 
                {
                    Write-Host "Pacckage $Packagename   is alrady there we will not create it again" -ForegroundColor Yellow
                    throw
                } 
            else {
                Write-Host "Pakcage not there we will create it now" -ForegroundColor Green
                # Crete paakge 
                New-CMPackage -Name $Packagename -Manufacturer $Company -Version $Version -Language $Language -Path $Path       
                }

        }
        catch {
            <#Do this if a terminating exception happens#>
            Write-Host $_ -ForegroundColor Blue
        }
        finally {
            <#Do this after the try block regardless of whether an exception occurred or not#>
            Write-Host "This is finaly block runs even for success and even for failure" -ForegroundColor Cyan
        }
     }
     end{
        Write-Host "Thank you - www.pcxlab.com " -ForegroundColor Yellow
     }
           
}

<#
MS-Document : 
https://learn.microsoft.com/en-us/powershell/module/configurationmanager/new-cmpackage?view=sccm-ps

Direct Command :
New-CMPackage -Name $Packagename -Manufacturer $Company -Version $Version -Language $Language -Path $Path       

Usage example ""
New-PCXCMPackage -Packagename "PKG_7zip_2.0.1" -Company "Igor_Pavlov" -Version "2.0.0" -Language "EN-US" -Path "\\192.168.25.214\Package_Source\Applications\Igor_Pavlov\7zip\7zip_2.0.0"
#>


