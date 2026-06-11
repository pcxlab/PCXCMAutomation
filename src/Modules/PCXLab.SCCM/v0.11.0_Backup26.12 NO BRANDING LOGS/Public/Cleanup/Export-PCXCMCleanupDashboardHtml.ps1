function Export-PCXCMCleanupDashboardHtml {

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
                ConvertTo-Html `
                    -Title 'PCXLab SCCM Cleanup Dashboard' `
                    -PreContent '<h1>PCXLab SCCM Cleanup Dashboard</h1>' |
                Out-File `
                    -FilePath $Path `
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