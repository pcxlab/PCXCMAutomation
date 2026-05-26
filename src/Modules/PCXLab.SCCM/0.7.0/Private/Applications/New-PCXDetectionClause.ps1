function New-PCXDetectionClause {

    [CmdletBinding()]
    param(

        [Parameter(Mandatory)]
        [System.IO.FileInfo]$Installer
    )

    try {

        $extension = $Installer.Extension.ToLower()

        switch ($extension) {

            # ==========================================================
            # MSI
            # ==========================================================

            ".msi" {

                return $null
            }

            # ==========================================================
            # EXE / BAT / CMD / PS1
            # ==========================================================

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

        throw "Failed to create detection clause. $($_.Exception.Message)"
    }
}