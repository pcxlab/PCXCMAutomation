function New-PCXCMApplication {

    [CmdletBinding()]
    param(

        [parameter(mandatory = $true, Position = 0)]
        [string]$Name,

        [parameter(mandatory = $true, Position = 1)]
        [string]$Description,

        [parameter(mandatory = $true, Position = 2)]
        [string]$Publisher,

        [parameter(mandatory = $true, Position = 3)]
        [string]$SoftwareVersion,

        [parameter(mandatory = $false, Position = 4)]
        [string]$Iconlocationfile,

        [parameter(mandatory = $true, Position = 5)]
        [string]$ReleaseDate
    )

    begin {
        Write-PCXOperationStart
    }

    process {
        try {
            $ExistingApp = Get-CMApplication -Name $Name -Fast -ErrorAction SilentlyContinue

            if ($ExistingApp) {
                throw "Application already exists: $Name"
            }

            Write-PCXLog "Creating application: $Name"

            if ($Iconlocationfile) {
            $null = New-CMApplication -Name "$Name" -Description "$Description" -Publisher "$Publisher" -SoftwareVersion "$SoftwareVersion" -OptionalReference "Reference" -ReleaseDate "$ReleaseDate" -AutoInstall $true -LocalizedName "Application01" -UserDocumentation "https://contoso.com/content" -LinkText "For more information" -LocalizedDescription "New Localized Application" -Keyword "application" -PrivacyUrl "https://contoso.com/library/privacy" -IsFeatured $true -IconLocationFile "$Iconlocationfile"
            }
            else {
            $null = New-CMApplication -Name "$Name" -Description "$Description" -Publisher "$Publisher" -SoftwareVersion "$SoftwareVersion" -OptionalReference "Reference" -ReleaseDate "$ReleaseDate" -AutoInstall $true -LocalizedName "Application01" -UserDocumentation "https://contoso.com/content" -LinkText "For more information" -LocalizedDescription "New Localized Application" -Keyword "application" -PrivacyUrl "https://contoso.com/library/privacy" -IsFeatured $true
            }

            Write-PCXLog "Application created: $Name"
        }
        catch {
            Write-PCXLog -Message "Failed to create application: $Name. $($_.Exception.Message)" -Level ERROR
throw
        }
    }
    end {
        Write-PCXOperationEnd -Status Success
    }
}


