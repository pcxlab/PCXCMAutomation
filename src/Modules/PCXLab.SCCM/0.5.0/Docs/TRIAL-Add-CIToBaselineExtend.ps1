# ------------------------------------------------------------
# CONFIG
# ------------------------------------------------------------
$BaselineName = "BLD-Windows-Parent"
$CIName = "CI-Windows-OS-Check"

# ------------------------------------------------------------
# GET OBJECTS (NO -Fast)
# ------------------------------------------------------------
$Baseline = Get-CMBaseline -Name $BaselineName
$CI = Get-CMConfigurationItem -Name $CIName

if (-not $Baseline) {
    throw "Baseline not found"
}

if (-not $CI) {
    throw "CI not found"
}

Write-Host "Baseline: $($Baseline.LocalizedDisplayName)"
Write-Host "CI: $($CI.LocalizedDisplayName) (ID: $($CI.CI_ID))"

# ------------------------------------------------------------
# ADD CI TO BASELINE (CORRECT PARAM)
# ------------------------------------------------------------
Set-CMBaseline `
    -Name $BaselineName `
    -AddRequiredConfigurationItemId $CI.CI_ID

Set-CMBaseline -Name "BLD-Windows-Parent" -AddRequiredConfigurationItem $CI.LocalizedDisplayName
# ------------------------------------------------------------
# VERIFY
# ------------------------------------------------------------
Start-Sleep -Seconds 2

(Get-CMBaseline -Name $BaselineName).RequiredConfigurationItems | Select-Object LocalizedDisplayName, CI_ID


$CI = Get-CMConfigurationItem -Name "CI-Windows-OS-Check"
$CI = Get-CMConfigurationItem -Id $CI.CI_ID

$BL = Get-CMBaseline -Name "BLD-Windows-Parent"
Set-CMBaseline -InputObject $BL -AddRequiredConfigurationItem $CI

(Get-CMBaseline -Name "BLD-Windows-Parent").RequiredConfigurationItems | Select LocalizedDisplayName, CI_ID
(Get-CMBaseline -Name "BLD-Windows-Parent").RequiredConfigurationItems | Select-Object LocalizedDisplayName, CI_ID

$CI | Select CI_ID, LocalizedDisplayName, IsLatest, IsEnabled, CIType_ID

Set-CMBaseline `
    -Name "BLD-Windows-Parent" `
    -AddRequiredConfigurationItem "$($CI.CI_ID)"


$CI_ID = $CI.CI_ID
$SiteCode = "PS1"   # change if needed

$BaselineWMI = Get-WmiObject -Namespace "root\SMS\site_$SiteCode" `
    -Class SMS_ConfigurationBaseline `
    -Filter "LocalizedDisplayName='BLD-Windows-Parent'"

$BaselineWMI.AddConfigurationItems($CI_ID)

Set-CMBaseline -Name "BLD-Windows-Parent" -AddRequiredConfigurationItem "$($CI.CI_ID)"

$SiteCode = "PS1"

$Baseline = Get-CimInstance -Namespace "root/SMS/site_$SiteCode" `
    -ClassName SMS_ConfigurationBaselineInfo `
    -Filter "LocalizedDisplayName='BLD-Windows-Parent'"

$CI_ID = $CI.CI_ID

Invoke-CimMethod -InputObject $Baseline `
    -MethodName AddConfigurationItems `
    -Arguments @{ CI_IDs = @($CI_ID) }