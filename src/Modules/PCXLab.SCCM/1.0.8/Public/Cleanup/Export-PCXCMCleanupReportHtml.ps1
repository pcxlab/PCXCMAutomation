function Export-PCXCMCleanupReportHtml {

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
                ConvertTo-Html |
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
