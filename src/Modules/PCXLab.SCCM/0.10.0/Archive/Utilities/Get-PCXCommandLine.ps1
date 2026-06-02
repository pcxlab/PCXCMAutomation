function Get-PCXCommandLine {

    [CmdletBinding()]
    param(

        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [System.IO.FileInfo]$Installer
    )

    # ==========================================================
    # BUILD STANDARD INSTALL COMMAND
    # ==========================================================

    switch ($Installer.Extension.ToLower()) {

        ".msi" {

            return "msiexec.exe /i `"$($Installer.Name)`" /qn"
        }

        ".exe" {

            return "`"$($Installer.Name)`" /S"
        }

        default {

            throw "Unsupported installer type: $($Installer.Extension)"
        }
    }
}

