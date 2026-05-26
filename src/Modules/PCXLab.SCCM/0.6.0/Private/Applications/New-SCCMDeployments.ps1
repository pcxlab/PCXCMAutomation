function New-SCCMDeployments {
    param(
        [Parameter(Mandatory)]
        [string]$PackageName,

        [Parameter(Mandatory)]
        [pscustomobject]$Programs,

        [Parameter(Mandatory)]
        [pscustomobject]$Collections,

        $DeadlineTime
    )

    $programComment = "$PackageName Program"

    New-CMPackageDeployment `
        -StandardProgram `
        -PackageName $PackageName `
        -CollectionName $Collections.Available `
        -Comment $programComment `
        -DeployPurpose Available `
        -ProgramName $Programs.Available

    if (-not $DeadlineTime) {
        $DeadlineTime = (Get-Date -Hour 20 -Minute 0 -Second 0).AddDays(30)
    }

    $schedule = New-CMSchedule -Start $DeadlineTime -Nonrecurring

    New-CMPackageDeployment `
        -StandardProgram `
        -PackageName $PackageName `
        -ProgramName $Programs.Install `
        -DeployPurpose Required `
        -CollectionName $Collections.Install `
        -Schedule $schedule

    New-CMPackageDeployment `
        -StandardProgram `
        -PackageName $PackageName `
        -ProgramName $Programs.Uninstall `
        -DeployPurpose Required `
        -CollectionName $Collections.Uninstall `
        -Schedule $schedule

    Write-PCXLog "Deployments created"
}