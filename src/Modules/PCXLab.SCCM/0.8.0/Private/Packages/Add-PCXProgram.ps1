function Add-PCXProgram {
    param(
        [string]$PackageName,
        [string]$Type,
        [string]$CommandLine,
        $Platforms
    )

    $name = "$PackageName [$Type]"

    # Default values
    $runType = "WhetherOrNotUserIsLoggedOn"
    $userInteraction = $false
    $runMode = "RunWithAdministrativeRights"

    # Special handling for AVAILABLE
    if ($Type -eq "Available") {
        $runType = "OnlyWhenUserIsLoggedOn"
        $userInteraction = $true
    }

    # Create Program
    Invoke-PCXWithRetry {
        New-CMProgram `
            -PackageName $PackageName `
            -StandardProgramName $name `
            -CommandLine $CommandLine `
            -AddSupportedOperatingSystemPlatform $Platforms `
            -RunMode $runMode `
            -ProgramRunType $runType `
            -UserInteraction $userInteraction `
            -RunType Normal `
            -DiskSpaceRequirement 5 `
            -DiskSpaceUnit GB `
            -Duration 20
    }

    # Post config ONLY for Available
    if ($Type -eq "Available") {
        Invoke-PCXWithRetry {
            Set-CMProgram `
                -PackageName $PackageName `
                -ProgramName $name `
                -StandardProgram `
                -SuppressProgramNotification $false
        }
    }

    Write-PCXLog "$Type program created: $name"
}