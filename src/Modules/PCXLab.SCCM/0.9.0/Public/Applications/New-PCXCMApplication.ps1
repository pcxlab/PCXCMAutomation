function New-PCXCMApplication {
    param(
        [parameter(mandatory = $true, Position = 0)]
        [string]$Name,

        [parameter(mandatory = $true, Position = 1)]
        [string]$Description,

        [parameter(mandatory = $true, Position = 2)] 
        [string]$Publisher,

        [parameter(mandatory = $true, Position = 3)] 
        [string]$SoftwereVersion,

        [parameter(mandatory = $true, Position = 4)]
        [string]$Iconlocationfile,

        [parameter(mandatory = $true, Position = 5)]
        [string]$ReleaseDate
    )
    begin {
        Write-PCXLog "BEGIN - PCXLab Automation"
    }

    process {
        try {
            Write-PCXLog "Creating application: $Name"
            $null = New-CMApplication -Name "$Name" -Description "$Description" -Publisher "$Publisher"  -SoftwareVersion "$SoftwereVersion" -OptionalReference "Reference" -ReleaseDate "$ReleaseDate" -AutoInstall $True -Owner "Administrator" -SupportContact "Administrator" -LocalizedName "Application01" -UserDocumentation "https://contoso.com/content" -LinkText "For more information" -LocalizedDescription "New Localized Application" -Keyword "application" -PrivacyUrl "https://contoso.com/library/privacy" -IsFeatured $True -IconLocationFile "$Iconlocationfile"
            Write-PCXLog "Application created: $Name"
        }
        catch {
            Write-PCXLog "Failed to create application: $Name. $_"
            throw
        }
        finally {
            Write-PCXLog "Application operation completed: $Name"
        }
    }
    end {
        Write-PCXLog "END - www.pcxlab.com"
    }
}
 
<# 
    MS Document :
    https://learn.microsoft.com/en-us/powershell/module/configurationmanager/new-cmapplication?view=sccm-ps

    Direct command Line
    New-CMApplication -Name "APS_7zip_26.0.1" -Description "New Application" -Publisher "Igor-Pavlov" -SoftwareVersion "26.00" -ReleaseDate "2/12/2026" -Iconlocationfile "\\192.168.25.214\Package_Source\Applications\Igor_Pavlov\7Zip_msi\7zip_26.0.0\7ZipIcon.png"

    Function Usage example :
    New-PCXCMApplication -Name "APS_7zip_26.0.1" -Description "New Application" -Publisher "Igor-Pavlov" -SoftwereVersion "26.00" -ReleaseDate "2/12/2026" -Iconlocationfile "\\192.168.25.214\Package_Source\Applications\Igor_Pavlov\7Zip_msi\7zip_26.0.0\7ZipIcon.png"
  #>

    
#New-PCXCMApplication -Name "APS_7zip_26.0.1" -Description "New Application" -Publisher "Igor-Pavlov" -SoftwereVersion "26.00" -ReleaseDate "2/12/2026" -Iconlocationfile "\\192.168.25.214\Package_Source\Applications\Igor Pavlov\7zip\7zip 26.0.0\7ZipIcon.png"
  
   