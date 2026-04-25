# Auto load Private
Get-ChildItem -Path "$PSScriptRoot\Private\*.ps1" -Recurse -ErrorAction SilentlyContinue |
Sort-Object FullName |
ForEach-Object { . $_.FullName }

# Auto load Classes
Get-ChildItem -Path "$PSScriptRoot\Classes\*.ps1" -Recurse -ErrorAction SilentlyContinue |
Sort-Object FullName |
ForEach-Object { . $_.FullName }

# Auto load Public
Get-ChildItem -Path "$PSScriptRoot\Public\*.ps1" -Recurse -ErrorAction SilentlyContinue |
Sort-Object FullName |
ForEach-Object { . $_.FullName }