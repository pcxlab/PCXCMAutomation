function Export-PCXCMCleanupDashboardCsv {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Path
    )

    begin {

        Write-PCXOperationStart
    }

    process {

        try {

            $ResultCleanupDashboard = Get-PCXCMCleanupDashboard

            $ResultCleanupDashboard |
                Export-Csv `
                    -Path $Path `
                    -NoTypeInformation `
                    -Encoding UTF8
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
