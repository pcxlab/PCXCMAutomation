function New-PCXCMPackageProgramNames {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Company,

        [Parameter(Mandatory)]
        [string]$Product,

        [Parameter()]
        [string]$Version
    )

    $MaxLength = 50

    $Types = @(
        "Available",
        "Install",
        "Uninstall",
        "Upgrade",
        "Rollback",
        "Cleanup",
        "Reinstall",
        "OSD"
    )

    #
    # Candidate naming levels (most descriptive -> least descriptive)
    #
    $Levels = @(
        "PKG $Company $Product $Version",
        "$Company $Product $Version",
        "$Product $Version",
        "$Product",
        ""
    )

    foreach ($Level in $Levels) {

        $Fits = $true

        foreach ($Type in $Types) {

            if ([string]::IsNullOrWhiteSpace($Level)) {
                $ProgramName = "[$Type]"
            }
            else {
                $ProgramName = "$Level [$Type]"
            }

            $ProgramName = ($ProgramName -replace '\s+', ' ').Trim()

            if ($ProgramName.Length -gt $MaxLength) {
                $Fits = $false
                break
            }
        }

        if ($Fits) {

            $Result = [ordered]@{}

            foreach ($Type in $Types) {

                if ([string]::IsNullOrWhiteSpace($Level)) {
                    $Result[$Type] = "[$Type]"
                }
                else {
                    $Result[$Type] = (($Level + " [$Type]") -replace '\s+', ' ').Trim()
                }
            }

            return [PSCustomObject]$Result
        }
    }

    #
    # Should never happen
    #
    return [PSCustomObject]@{
        Available = "[Available]"
        Install   = "[Install]"
        Uninstall = "[Uninstall]"
        Upgrade   = "[Upgrade]"
        Rollback  = "[Rollback]"
        Cleanup   = "[Cleanup]"
        Reinstall = "[Reinstall]"
        OSD       = "[OSD]"
    }
}