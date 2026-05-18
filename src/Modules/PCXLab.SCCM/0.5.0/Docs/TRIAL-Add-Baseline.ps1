# ------------------------------------------------------------
# STEP 1: Create Parent Baseline
# This is the main (top-level) baseline
# ------------------------------------------------------------
$ParentBaselineName = "BLD-Windows-Parent"

$ParentBaseline = New-CMBaseline `
    -Name $ParentBaselineName `
    -Description "Main Windows compliance baseline (Parent)"


# Creation of Baseline 1 (Parent)
New-CMBaseline `
    -Name "BLD-Windows-Parent" `
    -Description "Main Windows compliance baseline (Parent)"


# Creation of Baseline 2 (Child)
New-CMBaseline `
    -Name "BLD-Windows-Child" `
    -Description "Main Windows compliance baseline (Parent)"
    

# Adding Objects to Varialbe
$ParentBaselineObject = Get-CMBaseline -Name "BLD-Windows-Parent"
$ChildBaselineObject = Get-CMBaseline -Name "BLD-Windows-Child"

# Getting the CI ID
$ChildBaselineID = $ChildBaselineObject.CI_ID

# Adding Child Baseline to Parent Baseleine
Set-CMBaseline `
    -InputObject $ParentBaselineObject `
    -AddBaseline $ChildBaselineID

# ------------------------------------------------------------
# STEP 2: Create Child Baseline
# This baseline will be nested inside the parent
# ------------------------------------------------------------
$ChildBaselineName = "BLD-Windows-Child"

$ChildBaseline = New-CMBaseline `
    -Name $ChildBaselineName `
    -Description "Child baseline for modular compliance checks"

New-CMBaseline `
    -Name "BLD-Windows-Child1" `
    -Description "Child baseline for modular compliance checks"

# ------------------------------------------------------------
# STEP 3: Retrieve Baselines from SCCM
# Using -Fast improves performance (no lazy property loading)
# Select-Object -First 1 ensures only one object is returned
# ------------------------------------------------------------
$ParentBaselineObject = Get-CMBaseline -Name $ParentBaselineName -Fast | Select-Object -First 1
$ChildBaselineObject = Get-CMBaseline -Name $ChildBaselineName  -Fast | Select-Object -First 1

# ------------------------------------------------------------
# STEP 4: Add Child Baseline to Parent Baseline
# IMPORTANT:
# SCCM requires the CI_ID (integer), not the name or full object
# ------------------------------------------------------------
$ChildBaselineID = $ChildBaselineObject.CI_ID

Set-CMBaseline `
    -InputObject $ParentBaselineObject `
    -AddBaseline $ChildBaselineID

# ------------------------------------------------------------
# STEP 5: Verification (optional)
# Displays baselines linked to the parent
# ------------------------------------------------------------
(Get-CMBaseline -Name $ParentBaselineName).RequiredConfigurationItems

########### line by line


