function Add-PCXCMPackageProgram {
    param(
        [Parameter(Mandatory)]
        [string]$PackageName,

        [Parameter(Mandatory)]
        [string]$Type,

        [Parameter(Mandatory)]
        [string]$CommandLine,

        [Parameter(Mandatory)]
        $Platforms
    )

    begin {
        Write-PCXOperationStart
    }

    process {
        try {
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
            $null = New-CMProgram `
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

            # Post config ONLY for Available
            if ($Type -ieq "Available") {
                $null = Set-CMProgram `
                    -PackageName $PackageName `
                    -ProgramName $name `
                    -StandardProgram `
                    -SuppressProgramNotification $false
            }

            Write-PCXLog "$Type program created: $name"
        }
        catch {
            Write-PCXLog -Message "Failed to create $Type program for $PackageName. $($_.Exception.Message)" -Level ERROR
            throw
        }
    }

    end {
        Write-PCXOperationEnd
    }
}


