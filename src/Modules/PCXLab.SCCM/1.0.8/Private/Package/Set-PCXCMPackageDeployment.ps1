function Set-PCXCMPackageDeployment {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$PackageName,

        [Parameter(Mandatory)]
        [string]$ProgramName,

        [Parameter(Mandatory)]
        [string]$CollectionName,

        [Parameter()]
        [bool]$UseMeteredNetwork = $true
    )

    begin {
        Write-PCXOperationStart
    }

    process {
        try {
            Write-PCXLog -Message "Updating package deployment settings for Package [$PackageName], Program [$ProgramName], Collection [$CollectionName], UseMeteredNetwork [$UseMeteredNetwork]" -Level INFO

            Set-CMPackageDeployment `
                -PackageName $PackageName `
                -StandardProgramName $ProgramName `
                -CollectionName $CollectionName `
                -UseMeteredNetwork $UseMeteredNetwork `
                -ErrorAction Stop

            Write-PCXLog -Message "Successfully updated package deployment settings for Package [$PackageName]" -Level INFO
        }
        catch {
            Write-PCXLog -Message "Failed to update package deployment settings for Package [$PackageName]. Error: $($_.Exception.Message)" -Level ERROR
            throw
        }
    }

    end {
        Write-PCXOperationEnd
    }
}
