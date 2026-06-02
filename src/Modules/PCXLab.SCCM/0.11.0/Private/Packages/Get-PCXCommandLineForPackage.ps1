function Get-PCXCommandLineForPackage {
    param(
        [string]$Path,
        [string]$Type,
        $Installer
    )

    $map = @{}

    # Safe filesystem enumeration (avoids SCCM PSDrive/provider issues)
    [System.IO.Directory]::GetFiles($Path) | ForEach-Object {

        $file = [System.IO.FileInfo]$_

        $map[$file.Name.ToLower()] = $file
    }

    switch ($Type) {

        "Install" {

            if ($map.ContainsKey("install.bat")) {
                return "cmd.exe /c install.bat"
            }

            if ($Installer.Extension -eq ".msi") {
                return "msiexec /i `"$($Installer.Name)`" /qn"
            }

            return "$($Installer.Name) /S"
        }

        "Uninstall" {

            if ($map.ContainsKey("uninstall.bat")) {
                return "cmd.exe /c uninstall.bat"
            }

            if ($Installer.Extension -eq ".msi") {
                return "msiexec /x `"$($Installer.Name)`" /qn"
            }

            return "$($Installer.Name) /uninstall /S"
        }

        "Upgrade" {

            if ($map.ContainsKey("upgrade.bat")) {
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


