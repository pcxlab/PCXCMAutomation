function Get-PCXCMPackagePrograms {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        $Installer,

        [Parameter(Mandatory)]
        $FileMap
    )

    $Programs = @()

    # Built-in programs
    $Programs += [PSCustomObject]@{
        Type = "Available"
        Command = Get-PCXCMCommandLineForPackage -Type "Available" -Installer $Installer -FileMap $FileMap
    }

    $Programs += [PSCustomObject]@{
        Type = "Install"
        Command = Get-PCXCMCommandLineForPackage -Type "Install" -Installer $Installer -FileMap $FileMap
    }

    $Programs += [PSCustomObject]@{
        Type = "Uninstall"
        Command = Get-PCXCMCommandLineForPackage -Type "Uninstall" -Installer $Installer -FileMap $FileMap
    }

    $Programs += [PSCustomObject]@{
        Type = "OSD"
        Command = Get-PCXCMCommandLineForPackage -Type "OSD" -Installer $Installer -FileMap $FileMap
    }

    # Discover every other BAT automatically
    foreach ($File in $FileMap.Values) {

        if ($File.Extension -ne ".bat") {
            continue
        }

        $ProgramName = [System.IO.Path]::GetFileNameWithoutExtension($File.Name)

        if ($ProgramName -in @("Install","Uninstall")) {
            continue
        }

        $Programs += [PSCustomObject]@{
            Type = $ProgramName
            Command = "cmd.exe /c `"$($File.Name)`""
        }
    }

    return $Programs | Sort-Object Type -Unique
}