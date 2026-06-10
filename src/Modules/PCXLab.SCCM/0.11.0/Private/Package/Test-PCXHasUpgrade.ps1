function Test-PCXHasUpgrade {
    param([Parameter(Mandatory)]$FileMap)

    $FileMap.ContainsKey("upgrade.bat")
}


