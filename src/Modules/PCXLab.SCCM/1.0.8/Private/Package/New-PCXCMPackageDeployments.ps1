function New-PCXCMPackageDeployments {
    param(
        [Parameter(Mandatory)]
        [string]$PackageName,

        [Parameter(Mandatory)]
        [pscustomobject]$Programs,

        [Parameter(Mandatory)]
        [pscustomobject]$Collections,

        $DeadlineTime
    )

    begin {
        Write-PCXOperationStart
    }

    process {
        try {
            $programComment = "$PackageName Program"

            # Available Deployment
            $null = New-CMPackageDeployment `
                -StandardProgram `
                -PackageName $PackageName `
                -CollectionName $Collections.Available `
                -Comment $programComment `
                -DeployPurpose Available `
                -ProgramName $Programs.Available `
                -FastNetworkOption DownloadContentFromDistributionPointAndRunLocally `
                -SlowNetworkOption DownloadContentFromDistributionPointAndLocally `
                -AllowFallback $true

            if (-not $DeadlineTime) {
                $DeadlineTime = (Get-Date -Hour 10 -Minute 0 -Second 0).AddDays(5)
            }

            $InstallDeadLineTime = (Get-Date -Hour 10 -Minute 0 -Second 0).AddDays(5)
            $UninstallDeadLineTime = (Get-Date -Hour 10 -Minute 0 -Second 0).AddDays(7)

            $InstallSchedule = New-CMSchedule -DurationInterval Days -DurationCount 0 -RecurInterval Days -RecurCount 5 -Start $InstallDeadLineTime
            $UninstallSchedule = New-CMSchedule -Start $UninstallDeadLineTime -Nonrecurring

            # Install Deployment
            $null = New-CMPackageDeployment `
                -StandardProgram `
                -PackageName $PackageName `
                -ProgramName $Programs.Install `
                -DeployPurpose Required `
                -CollectionName $Collections.Install `
                -Schedule $InstallSchedule `
                -FastNetworkOption DownloadContentFromDistributionPointAndRunLocally `
                -SlowNetworkOption DownloadContentFromDistributionPointAndLocally `
                -SendWakeupPacket $true `
                -UseMeteredNetwork $true `
                -RerunBehavior RerunIfFailedPreviousAttempt `
                -AllowUsersRunIndependently $true `
                -AllowFallback $true `
                -SoftwareInstallation $true 

            # Uninstall Deployment
            $null = New-CMPackageDeployment `
                -StandardProgram `
                -PackageName $PackageName `
                -ProgramName $Programs.Uninstall `
                -DeployPurpose Required `
                -CollectionName $Collections.Uninstall `
                -Schedule $UninstallSchedule `
                -FastNetworkOption DownloadContentFromDistributionPointAndRunLocally `
                -SlowNetworkOption DownloadContentFromDistributionPointAndLocally `
                -SendWakeupPacket $true `
                -UseMeteredNetwork $true `
                -RerunBehavior RerunIfFailedPreviousAttempt `
                -AllowFallback $true `
                -SoftwareInstallation $true 

            Write-PCXLog "Deployments created"
        }
        catch {
            Write-PCXLog -Message "Failed to create deployments. $($_.Exception.Message)" -Level ERROR
            throw
        }
    }

    end {
        Write-PCXOperationEnd
    }
}


