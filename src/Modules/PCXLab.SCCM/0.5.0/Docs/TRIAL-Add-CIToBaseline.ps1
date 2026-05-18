# ------------------------------------------------------------
# STEP 1: Define Names
# ------------------------------------------------------------
$ParentBaselineName = "BLD-Windows-Parent"
$ConfigItemName = "CI-Windows-OS-Check"

# ------------------------------------------------------------
# STEP 2: Ensure Parent Baseline Exists
# ------------------------------------------------------------
$ParentBaselineObject = Get-CMBaseline -Name $ParentBaselineName -Fast | Select-Object -First 1

if (-not $ParentBaselineObject) {

    Write-Host "Creating Parent Baseline..." -ForegroundColor Cyan

    $ParentBaselineObject = New-CMBaseline `
        -Name $ParentBaselineName `
        -Description "Main Windows compliance baseline"
}

# ------------------------------------------------------------
# STEP 3: Create Configuration Item
# ------------------------------------------------------------
$ConfigItem = New-CMConfigurationItem `
    -Name $ConfigItemName `
    -CreationType WindowsOS `
    -Description "Checks basic Windows OS compliance"


# Create CI Configuration Item
New-CMConfigurationItem `
    -Name "CI-Windows-OS-Check" `
    -CreationType WindowsOS `
    -Description "Checks basic Windows OS compliance"

# ------------------------------------------------------------
# STEP 4: Add CI to Baseline
# ------------------------------------------------------------
Set-CMBaseline `
    -InputObject $ParentBaselineObject `
    -AddRequiredConfigurationItem $ConfigItem.CI_ID

# ------------------------------------------------------------
# STEP 5: Verify
# ------------------------------------------------------------
(Get-CMBaseline -Name $ParentBaselineName).RequiredConfigurationItems