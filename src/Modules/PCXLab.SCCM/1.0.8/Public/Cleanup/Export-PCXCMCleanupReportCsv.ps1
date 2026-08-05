function Export-PCXCMCleanupReportCsv {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [object]$InputObject,

        [Parameter(Mandatory)]
        [string]$Path
    )

    begin {

        Write-PCXOperationStart
    }

    process {

        try {

            $InputObject |
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
