Import-Module .\src\Modules\PCXLab.SCCM

new-pcxcmcomment -reviewer "David" -requestnumber "INC123456" -comment "Google Chrome package"  

$comment = new-pcxcmcomment -reviewer "David" -requestnumber "INC123456" -comment "Google Chrome package"  

$comment

Get-ChildItem C:\Projects\PCXLABCMAutomation\src\Modules\PCXLab.SCCM\1.0.2 -Recurse -File |
    Select-String -Pattern '\bGet-PCXCMPackagePrograms\b'

    Get-ChildItem C:\Projects\PCXLABCMAutomation\src\Modules\PCXLab.SCCM\1.0.2 -Recurse -File |
    Select-String -Pattern '\bGet-PCXCMPackagePrograms\b' |
    Select-Object Path, LineNumber, Line

Get-ChildItem C:\Projects\PCXLABCMAutomation -Recurse -File |
    Select-String -Pattern '\bGet-PCXCMPackagePrograms\b'

    Get-ChildItem C:\Projects\PCXLABCMAutomation\src\Modules\PCXLab.SCCM\1.0.2 -Recurse -File |
    Select-String -Pattern '\bGet-PCXCMPackagePrograms\b' |
    Select-Object Path, LineNumber, Line

    ###################################
Connect-PCXCMSite
    Run:

Get-ChildItem C:\Projects\PCXLABCMAutomation\src\Modules\PCXLab.SCCM\1.0.2 -Recurse -File |
    Select-String 'function Get-PCXCMPackagePrograms'

This tells us whether the function itself exists and where.

Step 2 - Find Create-PCXCMPackage

Run:

Get-ChildItem C:\Projects\PCXLABCMAutomation\src\Modules\PCXLab.SCCM\1.0.2 -Recurse -File |
    Select-String 'Create-PCXCMPackage'

Open the file it reports and verify it actually contains:

$PackagePrograms = Get-PCXCMPackagePrograms -Installer $Installer -FileMap $FileMap

If not, your changes haven't been saved yet.

Step 3 - Check if the function is loaded
Get-Command Get-PCXCMPackagePrograms

If it returns nothing, the module currently loaded doesn't contain the function.

One more thing

Looking at your search command:

Select-String -Pattern '\bGet-PCXCMPackagePrograms\b'

The regex is fine, but for PowerShell function names I usually just search the literal string:

Get-ChildItem C:\Projects\PCXLABCMAutomation\src\Modules\PCXLab.SCCM\1.0.2 -Recurse -File |
    Select-String 'Get-PCXCMPackagePrograms'

It's simpler and avoids any regex edge cases.

Get-ChildItem C:\Projects\PCXLABCMAutomation\src\Modules\PCXLab.SCCM\1.0.2\Private\Package
Get-ChildItem C:\Projects\PCXLABCMAutomation\src\Modules\PCXLab.SCCM\1.0.2\Public\Package

Get-Command Get-PCXCMPackagePrograms


Get-ChildItem "$PSScriptRoot\Private" -Recurse -Filter *.ps1 |
    ForEach-Object {
        . $_.FullName
    }