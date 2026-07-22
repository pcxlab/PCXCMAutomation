function Create-PCXCMPackage {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Path,
        [string]$Language = "EN-US",
        [string[]]$DistributionPointGroups,
        [string[]]$DistributionPoints,
        [string]$LimitingCollectionName = (Get-PCXCMDefaultLimitingCollection),
        [string]$ReferenceNumber,
        [string]$ReviewerName,
        [string]$Comment
    )

    begin {
        #Write-PCXOperationStart
        Write-PCXOperationStart -OperationName $MyInvocation.MyCommand.Name
    }

    process {

        $OriginalLocation = Get-Location

        try {

            $Files = Test-PCXPackagePath $Path

            $FileMap = @{}
            foreach ($File in $Files) {
                $FileMap[$File.Name.ToLower()] = $File
            }

            $Installer = Get-PCXCMPackageInstaller $Files

            $Meta = Get-PCXMetadataFromPath $Path
            $PackageName = "PKG $($Meta.Name)"

            #$ProgramNames = New-PCXCMPackageProgramNames -PackageName $PackageName
            $ProgramNames = New-PCXCMPackageProgramNames -Company $Meta.Company -Product $Meta.Product -Version $Meta.Version

            $Collections = New-PCXCMDeploymentCollectionNames -ObjectName $PackageName

            Write-PCXLog "Package           : $PackageName"
            Write-PCXLog "Installer         : $($Installer.Name)"
            Write-PCXLog "Reference Number  : $ReferenceNumber"
            Write-PCXLog "Reviewer          : $ReviewerName"
            Write-PCXLog "Comment           : $Comment"

            # Resolve Package Icon
            $Icon = Get-PCXCMApplicationIcon -SourcePath $Path -Company $Meta.Company -Product $Meta.Product

            Write-PCXLog "Icon              : $($Icon)"
            Write-PCXLog "Icon Path         : $($Icon.Path)"

            if ($Icon.Found) {
                Write-PCXLog "Using application icon from $($Icon.Source)"
            }
            else {
                Write-PCXLog "No application icon found. Proceeding without icon." -Level WARNING
            }

            #based on the needed we il lchanges this.
            Ensure-PCXCMConnection
            #$null = Ensure-PCXCMConnection

            $Platforms = Get-CMSupportedPlatform -Fast | Where-Object { $_.DisplayText -like "*Windows 11*" }

            # Package Description
            $Description = New-PCXCMDescription -Reviewer $ReviewerName -RequestNumber $ReferenceNumber -Comment $Comment

            Write-PCXLog "Package Description :"
            Write-PCXLog $Description

            $null = New-PCXCMPackage -PackageName $PackageName -Company $Meta.Company -Version $Meta.Version -Language $Language -Path $Path -Description $Description

            # Set Package Icon
            if ($Icon.Found) {
                $null = Set-PCXCMPackageIcon -PackageName $PackageName -IconPath $Icon.Path
            }

            # Distribute Content
            $null = Start-PCXCMContentDistribution -PackageName $PackageName -DistributionPointGroups $DistributionPointGroups -DistributionPoints $DistributionPoints

            # Create Package Programs
            $PackagePrograms = Get-PCXCMPackagePrograms -Installer $Installer -FileMap $FileMap

            foreach ($PackageProgram in $PackagePrograms) {

                Write-PCXLog "Creating program: $($PackageProgram.Type)"
                Write-PCXLog "Source Path     : $Path"

                $ProgramName = $ProgramNames.($PackageProgram.Type)

                if ([string]::IsNullOrWhiteSpace($ProgramName)) {
                    throw "Failed to resolve program name for program type '$($PackageProgram.Type)'."
                }

                Write-PCXLog "Generated Program Name : $ProgramName"

                Add-PCXCMPackageProgram -PackageName $PackageName -ProgramName $ProgramName -SourcePath $Path -Type $PackageProgram.Type -CommandLine $PackageProgram.Command -Platforms $Platforms
            }

            # Create Collections
            New-PCXCMDeploymentDeviceCollections -Collections $Collections -LimitingCollectionName $LimitingCollectionName

            # Create Deployments
            $DeadlineTime = (Get-Date -Hour 10 -Minute 0 -Second 0).AddDays(7)

            New-PCXCMPackageDeployments -PackageName $PackageName -Programs $ProgramNames -Collections $Collections -DeadlineTime $DeadlineTime

            # Configure Collections
            $null = Set-PCXCMDeploymentCollectionRules -Collections $Collections

            # Move Objects
            $null = Move-PCXCMCollectionsToFolder -Collections $Collections -Meta $Meta -ObjectName $PackageName

            $null = Move-PCXCMPackageToFolder -Meta $Meta

            Write-PCXLog "SUCCESS: $PackageName"
        }
        catch {
            Write-PCXLog -Message $_.Exception.ToString() -Level ERROR
            throw
        }
        finally {

            try {
                Set-Location $OriginalLocation
            }
            catch {
            }
        }
    }

    end {
        Write-PCXOperationEnd
    }
}