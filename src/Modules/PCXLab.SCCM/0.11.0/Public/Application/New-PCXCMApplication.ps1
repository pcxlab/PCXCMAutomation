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

            $ApplicationParams = @{
                Name                 = $Name
                Description          = $Description
                Publisher            = $Publisher
                SoftwareVersion      = $SoftwareVersion
                OptionalReference    = "Reference"
                ReleaseDate          = $ReleaseDate
                AutoInstall          = $true
                LocalizedName        = $Name
                UserDocumentation    = "https://mphasis.com/"
                LinkText             = "Mphasis"
                LocalizedDescription = $Name
                Keyword              = $Name
                PrivacyUrl           = "https://mphasis.com/"
                IsFeatured           = $false
                ErrorAction          = "Stop"
            }

            if ($Iconlocationfile) {
                $ApplicationParams["IconLocationFile"] = $Iconlocationfile
            }

            $null = New-CMApplication @ApplicationParams

            Write-PCXLog "Application created: $Name"
        }
        catch {
            Write-PCXLog -Message "Failed to create application: $Name. $($_.Exception.Message)" -Level ERROR
            throw
        }
    }
    end {
        Write-PCXOperationEnd
    }
}


