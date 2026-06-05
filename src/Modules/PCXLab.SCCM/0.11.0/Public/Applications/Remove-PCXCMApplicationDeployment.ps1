function Remove-PCXCMApplicationDeployment {

    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [psobject]$CleanupInfo
    )

    begin {
        Write-PCXOperationStart
    }

    process {
        try {

            Ensure-PCXCMConnection

            if (-not $CleanupInfo.Deployments) {

                Write-PCXLog -Message 'No application deployments found.'
                return
            }

            $Deployments = $CleanupInfo.Deployments |
            Sort-Object {
                switch -Regex ($_.CollectionName) {
                    '\[INSTALL\]' { 1; break }
                    '\[EXCLUDE\]' { 2; break }
                    '\[UNINSTALL\]' { 3; break }
                    '\[AVAILABLE\]' { 4; break }
                    default { 99 }
                }
            }

            foreach ($Deployment in $Deployments) {

                if ($PSCmdlet.ShouldProcess($Deployment.CollectionName, 'Remove Application Deployment')) {

                    Write-PCXLog -Message "Removing Deployment: $($Deployment.CollectionName) [$($Deployment.AssignmentID)]"

                    Remove-CMApplicationDeployment -InputObject $Deployment -Force -ErrorAction Stop

                    Write-PCXLog -Message "Removed Deployment: $($Deployment.CollectionName) [$($Deployment.AssignmentID)]"
                }
            }
        }
        catch {

            Write-PCXLog -Message $_.Exception.Message -Level ERROR
            throw
        }
    }

    end {
        Write-PCXOperationEnd
    }
}