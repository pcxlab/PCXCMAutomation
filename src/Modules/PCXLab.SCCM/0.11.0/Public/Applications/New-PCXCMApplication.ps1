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
        [string]$SoftwereVersion,

        [parameter(mandatory = $true, Position = 4)]
        [string]$Iconlocationfile,

        [parameter(mandatory = $true, Position = 5)]
        [string]$ReleaseDate
    )

    begin {
        Write-PCXOperationStart
    }

    process {
        try {
            Write-PCXLog "Creating application: $Name"
            #$null = New-CMApplication -Name "$Name" -Description "$Description" -Publisher "$Publisher" -SoftwareVersion "$SoftwereVersion" -OptionalReference "Reference" -ReleaseDate "$ReleaseDate" -AutoInstall $true -Owner "Administrator" -SupportContact "Administrator" -LocalizedName "Application01" -UserDocumentation "https://contoso.com/content" -LinkText "For more information" -LocalizedDescription "New Localized Application" -Keyword "application" -PrivacyUrl "https://contoso.com/library/privacy" -IsFeatured $true -IconLocationFile "$Iconlocationfile"
            $null = New-CMApplication -Name "$Name" -Description "$Description" -Publisher "$Publisher" -SoftwareVersion "$SoftwereVersion" -OptionalReference "Reference" -ReleaseDate "$ReleaseDate" -AutoInstall $true -LocalizedName "Application01" -UserDocumentation "https://contoso.com/content" -LinkText "For more information" -LocalizedDescription "New Localized Application" -Keyword "application" -PrivacyUrl "https://contoso.com/library/privacy" -IsFeatured $true -IconLocationFile "$Iconlocationfile"
            Write-PCXLog "Application created: $Name"
        }
        catch {
            Write-PCXLog "Failed to create application: $Name. $($_.Exception.Message)" "ERROR"
throw
        }
    }
    end {
        Write-PCXOperationEnd -Status Success
    }
}

