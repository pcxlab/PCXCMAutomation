function New-PCXDetectionClause {

    [CmdletBinding()]
    param(

        [Parameter(Mandatory)]
        [System.IO.FileInfo]$Installer
    )

    begin {
        Write-PCXLog "BEGIN - PCXLab Automation"
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
            Write-PCXLog "Failed to create detection clause. $($_.Exception.Message)" "ERROR"
            throw
        }
        finally {
            Write-PCXLog "Detection clause operation completed: $($Installer.Name)"
        }
    }
    end {
        Write-PCXLog "END - www.pcxlab.com"
    }
}