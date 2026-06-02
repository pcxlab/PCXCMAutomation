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
        [string]$Path
    )

    begin {

        Write-PCXOperationStart
    }
    process {
        try {
            # Assign package object to variable
            $Package = Get-CMPackage -Name $PackageName -ErrorAction SilentlyContinue

            # Check whether package already exists
            if ($Package -ne $null) {
                Write-PCXLog "Package already exists: $PackageName"
                throw "Package already exists: $PackageName"
            }

            Write-PCXLog "Creating package: $PackageName"

            $null = New-CMPackage `
                -Name $PackageName `
                -Manufacturer $Company `
                -Version $Version `
                -Language $Language `
                -Path $Path

            Write-PCXLog "Package created: $PackageName"
        }
        catch {
            Write-PCXLog "Failed to create package: $PackageName. $($_.Exception.Message)" "ERROR"
throw
        }   
    }
    end {
        Write-PCXOperationEnd -Status Success
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



