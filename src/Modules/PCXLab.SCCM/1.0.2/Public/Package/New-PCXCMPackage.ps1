function New-PCXCMPackage {

    [CmdletBinding()]
    param (
        [parameter(Mandatory = $true, Position = 0)] 
        [string]$PackageName,

        [parameter(Mandatory = $true, Position = 1)] 
        [string]$Company,

        [parameter(Mandatory = $true, Position = 2)] 
        [string]$Version,

        [parameter(Mandatory = $false, Position = 3)]
        [string]$Language = "EN-US",

        [parameter(Mandatory = $true, Position = 4)]  
        [string]$Path,

        [parameter(Mandatory = $false)]
        [string]$Description
    )

    begin {

        Write-PCXOperationStart
    }
    process {
        try {
            if (Test-PCXCMPackageExists -PackageName $PackageName) {
                throw "Package already exists: $PackageName"
            }
            
            Write-PCXLog "Creating package: $PackageName"

            #$Package = New-CMPackage -Name $PackageName -Manufacturer $Company -Version $Version -Language $Language -Path $Path -Description $Description -ErrorAction Stop

            $Params = @{
                Name         = $PackageName
                Manufacturer = $Company
                Version      = $Version
                Language     = $Language
                Path         = $Path
                ErrorAction  = 'Stop'
            }
            
            if ($Description) {
                $Params.Description = $Description
            }
            
            $Package = New-CMPackage @Params

            Write-PCXLog "Package created: $PackageName"
            
            $Priority = Get-PCXCMPackageDistributionPriority
            Set-CMPackage -InputObject $Package -Priority $Priority -ErrorAction Stop
            Write-PCXLog "Distribution Priority: $Priority"

            return $Package
        }
        catch {
            Write-PCXLog -Message "Failed to create package $PackageName. $($_.Exception.Message)" -Level ERROR
            throw
        }   
    }
    end {
        Write-PCXOperationEnd
    }
}

<#
MS-Document :
https://learn.microsoft.com/en-us/powershell/module/configurationmanager/new-cmpackage?view=sccm-ps

Direct Command :
New-CMPackage -Name $PackageName -Manufacturer $Company -Version $Version -Language $Language -Path $Path

Usage Example :
New-PCXCMPackage -PackageName "PKG_7zip_2.0.1" -Company "Igor_Pavlov" -Version "2.0.0" -Language "EN-US" -Path "\\192.168.25.214\Package_Source\Applications\Igor_Pavlov\7zip\7zip_2.0.0"
#>




