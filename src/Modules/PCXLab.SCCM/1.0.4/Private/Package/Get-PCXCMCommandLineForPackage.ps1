function Get-PCXCMCommandLineForPackage {
    param(
        [string]$Type,
        $Installer,
        [Parameter(Mandatory)]
        $FileMap
    )

    switch ($Type) {

        "Available" {

            if ($FileMap.ContainsKey("install.bat")) {
                return "cmd.exe /c install.bat"
            }

            if ($Installer.Extension -eq ".msi") {
                return "$env:windir\System32\msiexec.exe /i `"$($Installer.Name)`""
            }

            return "$($Installer.Name)"
        }

        "Install" {

            if ($FileMap.ContainsKey("install.bat")) {
                return "cmd.exe /c install.bat"
            }

            if ($Installer.Extension -eq ".msi") {
                #return "msiexec /i `"$($Installer.Name)`" /qn"
                return "$env:windir\System32\msiexec.exe /i `"$($Installer.Name)`" /qn"
            }

            return "$($Installer.Name) /S"
        }

        "Uninstall" {

            if ($FileMap.ContainsKey("uninstall.bat")) {
                return "cmd.exe /c uninstall.bat"
            }

            if ($Installer.Extension -eq ".msi") {
                #return "msiexec /x `"$($Installer.Name)`" /qn"
                return "$env:windir\System32\msiexec.exe /x `"$($Installer.Name)`" /qn"
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
                #return "msiexec /i `"$($Installer.Name)`" /qn"
                return "$env:windir\System32\msiexec.exe /i `"$($Installer.Name)`" /qn"
            }

            return "$($Installer.Name)"
        }
    }
}



