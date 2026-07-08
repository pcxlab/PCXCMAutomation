function Get-PCXCMApplicationIcon {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$SourcePath,

        [Parameter(Mandatory)]
        [string]$Company,

        [Parameter(Mandatory)]
        [string]$Product
    )

    $Extensions = @(".ico", ".png", ".jpg", ".jpeg")

    try {

        $IconSettings = Get-PCXCMSetting -Name "IconSettings"

        if ($IconSettings.SupportedExtensions) {
            $Extensions = $IconSettings.SupportedExtensions
        }

        $CandidateNames = @(
            ("{0}{1}" -f $Company, $Product),
            ("{0} {1}" -f $Company, $Product),
            $Product
        ) | Select-Object -Unique

        Write-PCXLog "Searching for application icon..."

        #
        # Primary Search
        #

        foreach ($Name in $CandidateNames) {

            foreach ($Extension in $Extensions) {

                $Icon = Join-Path $SourcePath ($Name + $Extension)

                if (Test-Path $Icon) {

                    Write-PCXLog "Application icon found in source folder: $Icon"

                    return [PSCustomObject]@{
                        Found  = $true
                        Path   = $Icon
                        Source = "ApplicationFolder"
                    }

                }

            }

        }

        #
        # Secondary Search
        #

        if (-not $IconSettings.EnableSecondaryLookup) {

            Write-PCXLog "Secondary icon lookup is disabled."

            return [PSCustomObject]@{
                Found  = $false
                Path   = $null
                Source = "None"
            }

        }

        $SharedFolder = $IconSettings.SecondaryIconFolder

        if ([string]::IsNullOrWhiteSpace($SharedFolder)) {

            Write-PCXLog "Secondary icon folder not configured." -Level WARNING

            return [PSCustomObject]@{
                Found  = $false
                Path   = $null
                Source = "None"
            }

        }

        if (-not (Test-Path $SharedFolder)) {

            Write-PCXLog "Secondary icon folder not found: $SharedFolder" -Level WARNING

            return [PSCustomObject]@{
                Found  = $false
                Path   = $null
                Source = "None"
            }

        }

        foreach ($Name in $CandidateNames) {

            foreach ($Extension in $Extensions) {

                $Icon = Join-Path $SharedFolder ($Name + $Extension)

                if (Test-Path $Icon) {

                    Write-PCXLog "Application icon found in shared repository: $Icon"

                    return [PSCustomObject]@{
                        Found  = $true
                        Path   = $Icon
                        Source = "SharedRepository"
                    }

                }

            }

        }

        Write-PCXLog "No application icon found."

        return [PSCustomObject]@{
            Found  = $false
            Path   = $null
            Source = "None"
        }

    }
    catch {

        Write-PCXLog "Icon lookup failed: $($_.Exception.Message)" -Level WARNING

        return [PSCustomObject]@{
            Found  = $false
            Path   = $null
            Source = "None"
        }

    }

}