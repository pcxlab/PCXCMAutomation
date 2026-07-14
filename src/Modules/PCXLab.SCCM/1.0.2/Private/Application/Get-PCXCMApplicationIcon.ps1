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

        #
        # Use FileSystem provider because SCCM runs from the CMSite provider.
        #

        $FileSystemSourcePath = "FileSystem::$SourcePath"

        Write-PCXLog "Searching for application icon..."
        Write-PCXLog "Company           : $Company"
        Write-PCXLog "Product           : $Product"

        #
        # Primary Search
        #

        foreach ($Name in $CandidateNames) {

            foreach ($Extension in $Extensions) {

                $Icon = Join-Path $FileSystemSourcePath ($Name + $Extension)

                if (Test-Path -LiteralPath $Icon) {

                    $ResolvedIcon = $Icon -replace '^FileSystem::', ''

                    Write-PCXLog "Application icon found in source folder."
                    Write-PCXLog "Icon Path         : $ResolvedIcon"

                    return [PSCustomObject]@{
                        Found  = $true
                        Path   = $ResolvedIcon
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

            Write-PCXLog "Secondary icon folder is not configured." -Level WARNING

            return [PSCustomObject]@{
                Found  = $false
                Path   = $null
                Source = "None"
            }

        }

        $FileSystemSharedFolder = "FileSystem::$SharedFolder"

        if (-not (Test-Path -LiteralPath $FileSystemSharedFolder)) {

            Write-PCXLog "Secondary icon folder not found: $SharedFolder" -Level WARNING

            return [PSCustomObject]@{
                Found  = $false
                Path   = $null
                Source = "None"
            }

        }

        foreach ($Name in $CandidateNames) {

            foreach ($Extension in $Extensions) {

                $Icon = Join-Path $FileSystemSharedFolder ($Name + $Extension)

                if (Test-Path -LiteralPath $Icon) {

                    $ResolvedIcon = $Icon -replace '^FileSystem::', ''

                    Write-PCXLog "Application icon found in shared repository."
                    Write-PCXLog "Icon Path         : $ResolvedIcon"

                    return [PSCustomObject]@{
                        Found  = $true
                        Path   = $ResolvedIcon
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
