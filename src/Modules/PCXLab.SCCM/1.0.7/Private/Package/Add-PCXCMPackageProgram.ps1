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

            if ($Platforms) {
                $ProgramParams.AddSupportedOperatingSystemPlatform = $Platforms
            }

            Write-PCXLog "Package Name : $PackageName"
            Write-PCXLog "Program Name : $ProgramName"
            Write-PCXLog "Command Line : $CommandLine"

            $null = New-CMProgram @ProgramParams

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

            Write-PCXLog "Package Name : $PackageName"
            Write-PCXLog "Program Name : $ProgramName"
            Write-PCXLog "Type         : $Type"

            Write-PCXLog -Message "Failed to create $Type program for $PackageName. $($_.Exception.Message)" -Level ERROR
            throw
        }
    }

    end {
        Write-PCXOperationEnd
    }
}