function New-PCXCMApplication {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0)]
        [string]$ApplicationName,

        [Parameter(Mandatory, Position = 1)]
        [string]$Description,

        [Parameter(Mandatory, Position = 2)]
        [string]$Publisher,

        [Parameter(Mandatory, Position = 3)]
        [string]$SoftwareVersion,

        [Parameter(Mandatory = $false, Position = 4)]
        [string]$IconLocationFile,

        [Parameter(Mandatory, Position = 5)]
        [datetime]$ReleaseDate
    )

    begin {
        Write-PCXOperationStart
    }

    process {
        try {

            Ensure-PCXCMConnection

            if (Test-PCXCMApplicationExists -ApplicationName $ApplicationName) {
                throw "Application already exists: $ApplicationName"
            }

            Write-PCXLog "Creating application: $ApplicationName"

            $ApplicationParams = @{
                Name                 = $ApplicationName
                Description          = $Description
                Publisher            = $Publisher
                SoftwareVersion      = $SoftwareVersion
                OptionalReference    = "Reference"
                ReleaseDate          = $ReleaseDate
                AutoInstall          = $true
                LocalizedName        = $ApplicationName
                UserDocumentation    = "https://pcxlab.com/"
                LinkText             = "PCXLab"
                LocalizedDescription = $ApplicationName
                Keyword              = $ApplicationName
                PrivacyUrl           = "https://pcxlab.com/"
                IsFeatured           = $false
                ErrorAction          = "Stop"
            }

            if ($IconLocationFile) {
                $ApplicationParams["IconLocationFile"] = $IconLocationFile
            }

            $Application = New-CMApplication @ApplicationParams
            Write-PCXLog "Application created: $ApplicationName"
            return $Application
        }
        catch {

            $_ | Format-List * -Force

            Write-PCXLog `
                -Message $_.Exception.ToString() `
                -Level ERROR

            throw
        }
    }

    end {
        Write-PCXOperationEnd
    }
}