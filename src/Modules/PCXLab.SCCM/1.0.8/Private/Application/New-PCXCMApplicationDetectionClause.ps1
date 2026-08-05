function New-PCXCMApplicationDetectionClause {

    [CmdletBinding()]
    param(

        [Parameter(Mandatory)]
        [System.IO.FileInfo]$Installer
    )

    begin {
        Write-PCXOperationStart
    }

    process {
        try {
            $extension = $Installer.Extension.ToLower()

            switch ($extension) {
                # MSI
                ".msi" {

                    return $null
                }

                # EXE / BAT / CMD / PS1
                default {

                    $fileName = $Installer.Name

                    $clause = New-CMDetectionClauseFile `
                        -Path "C:\Program Files" `
                        -FileName $fileName `
                        -Existence

                    return $clause
                }
            }
        }
        catch {
            Write-PCXLog -Message "Failed to create detection clause. $($_.Exception.Message)" -Level ERROR
throw
        }
    }
    end {
        Write-PCXOperationEnd -Status Success
    }
}
