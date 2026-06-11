function Get-PCXInstaller {
    param($Files)

    $msi = $Files | Where-Object Extension -eq ".msi" | Select-Object -First 1
    if ($msi) { return $msi }

    $exe = $Files | Where-Object Extension -eq ".exe" | Select-Object -First 1
    if ($exe) { return $exe }

    throw "No installer found"
}


#Get-PCXInstaller -SourcePath "\\192.168.25.214\Package_Source\Applications\Google\Chrome\Google Chrome 145.0.7632.46"



