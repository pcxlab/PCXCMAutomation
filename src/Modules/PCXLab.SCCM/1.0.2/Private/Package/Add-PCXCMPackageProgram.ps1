function Add-PCXCMPackageProgram {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$PackageName,

        [Parameter(Mandatory)]
        [string]$ProgramName,

        [Parameter(Mandatory)]
        [string]$SourcePath,

        [Parameter(Mandatory)]
        [string]$Type,

        [Parameter(Mandatory)]
        [string]$CommandLine,

        [Parameter(Mandatory = $false)]
        $Platforms
    )

    begin {
        Write-PCXOperationStart
    }

    process {
        try {

            $SourceSize = Get-PCXSourceSize -Path $SourcePath

            $DiskSpace = Get-PCXEstimatedDiskSpace -SizeGB $SourceSize.GB

            $RunTime = Get-PCXMaximumRunTime -SizeMB $SourceSize.MB

            # Default values
            $runType = "WhetherOrNotUserIsLoggedOn"
            $userInteraction = $false
            $runMode = "RunWithAdministrativeRights"

            # Special handling for AVAILABLE
            if ($Type -eq "Available") {
                $runType = "OnlyWhenUserIsLoggedOn"
                $userInteraction = $true
            }

            # Build New-CMProgram parameters
            $ProgramParams = @{
                PackageName          = $PackageName
                StandardProgramName  = $ProgramName
                CommandLine          = $CommandLine
                RunMode              = $runMode
                ProgramRunType       = $runType
                UserInteraction      = $userInteraction
                RunType              = "Normal"
                DiskSpaceRequirement = $DiskSpace
                DiskSpaceUnit        = "GB"
                Duration             = $RunTime
            }

            # Only add supported platforms when supplied
            if ($Platforms) {
                $ProgramParams.AddSupportedOperatingSystemPlatform = $Platforms
            }

            Write-PCXLog "Package Name : $PackageName"
            Write-PCXLog "Program Name : $ProgramName"
            Write-PCXLog "Command Line : $CommandLine"

            # Create Program
            $null = New-CMProgram @ProgramParams

            # Post config ONLY for Available
            if ($Type -ieq "Available") {

                $null = Set-CMProgram `
                    -PackageName $PackageName `
                    -ProgramName $ProgramName `
                    -StandardProgram `
                    -SuppressProgramNotification $false
            }

            Write-PCXLog "$Type program created: $ProgramName"

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