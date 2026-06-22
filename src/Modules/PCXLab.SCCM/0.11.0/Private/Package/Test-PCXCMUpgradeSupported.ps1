function Test-PCXCMUpgradeSupported {
    param([Parameter(Mandatory)]$FileMap)

    $FileMap.ContainsKey("upgrade.bat")
}


