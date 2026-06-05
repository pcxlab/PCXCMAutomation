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

                $ApplicationName = $Name
                # Description will be calleer -Description $Description
                # Publisher is caller -Publisher $Publisher 
                # Sofware version is caller -SoftwareVersion $SoftwareVersion 
                $OptionalReference = "Reference"
                # Caller -ReleaseDate $ReleaseDate 
                # -AutoInstall $true 
                $LocalizedName = $ApplicationName
                
                $UserDocumentation = "https://mphasis.com/"
                #$UserDocumentation = "https://contoso.com/content" 
                $DocumentLinkText = "Mphasis" 
                $LocalizedDescription = $ApplicationName 
                $Keyword = $ApplicationName 
                $PrivacyUrl = "https://mphasis.com/"  
                #$PrivacyUrl = "https://contoso.com/library/privacy" 
                $IsFeatured = $false 
                # Caller -IconLocationFile "$Iconlocationfile"
            

            if ($Iconlocationfile) {
            $null = New-CMApplication -Name $ApplicationName -Description $Description -Publisher $Publisher -SoftwareVersion $SoftwareVersion -OptionalReference $OptionalReference -ReleaseDate $ReleaseDate -AutoInstall $true -LocalizedName $LocalizedName -UserDocumentation $UserDocumentation -LinkText $DocumentLinkText -LocalizedDescription $LocalizedDescription -Keyword $Keyword -PrivacyUrl $PrivacyUrl -IsFeatured $IsFeatured -IconLocationFile "$Iconlocationfile"
            }
            else {
            $null = New-CMApplication -Name $ApplicationName -Description $Description -Publisher $Publisher -SoftwareVersion $SoftwareVersion -OptionalReference $OptionalReference -ReleaseDate $ReleaseDate -AutoInstall $true -LocalizedName $LocalizedName -UserDocumentation $UserDocumentation -LinkText $DocumentLinkText -LocalizedDescription $LocalizedDescription -Keyword $Keyword -PrivacyUrl $PrivacyUrl -IsFeatured $IsFeatured
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


