function Get-PCXCommandLineForPackage {
    param(
        [string]$Type,
        $Installer,
        [Parameter(Mandatory)]
        $FileMap
    )

    switch ($Type) {

        "Install" {

            if ($FileMap.ContainsKey("install.bat")) {
                return "cmd.exe /c install.bat"
            }

            if ($Installer.Extension -eq ".msi") {
                return "msiexec /i `"$($Installer.Name)`" /qn"
            }

            return "$($Installer.Name) /S"
        }

        "Uninstall" {

            if ($FileMap.ContainsKey("uninstall.bat")) {
                return "cmd.exe /c uninstall.bat"
            }

            if ($Installer.Extension -eq ".msi") {
                return "msiexec /x `"$($Installer.Name)`" /qn"
            }

            return "$($Installer.Name) /uninstall /S"
        }

        "Upgrade" {

            if ($FileMap.ContainsKey("upgrade.bat")) {
                return "cmd.exe /c upgrade.bat"
            }

            return $null
        }

        "OSD" {

            if ($Installer.Extension -eq ".msi") {
                return "msiexec /i `"$($Installer.Name)`" /qn"
            }

            return "$($Installer.Name)"
        }
    }
}



