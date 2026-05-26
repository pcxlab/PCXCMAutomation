<#
Get-CMGlobalCondition
Get-CMSupportedPlatform
Get-CMSupportedPlatform | Select-Object DisplayText
Get-CMGlobalCondition | Select-Object name
New-CMRequirementRuleOperatingSystemValue
Set-CMScriptDeploymentType
#>

function Add-PCXCMApplicationWindows11Requirement {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$ApplicationName,

        [Parameter(Mandatory)]
        [string]$DeploymentTypeName
    )

    try {

        Write-PCXLog "Adding Windows 11 requirement to application: $ApplicationName"

        <# Get Windows 11 platform objects
        $Windows11Platforms = Get-CMSupportedPlatform | Where-Object {
            $_.LocalizedDisplayName -like "*Windows 11*64-bit*"
        }        
        #>

        # Get Windows 11 platform objects
        $Windows11Platforms = Get-CMSupportedPlatform | Where-Object {
            $_.DisplayText -like "*Windows*"
        }

        if (-not $Windows11Platforms) {
            throw "Windows 11 platform objects not found."
        }

        # Create requirement rule
        $RequirementRule = New-CMRequirementRuleOperatingSystemValue `
            -RuleOperator OneOf `
            -SupportedOperatingSystemPlatform $Windows11Platforms

        # Apply rule to Deployment Type
        Set-CMScriptDeploymentType `
            -ApplicationName $ApplicationName `
            -DeploymentTypeName $DeploymentTypeName `
            -AddRequirement $RequirementRule

        Write-PCXLog "Windows 11 requirement added successfully."
    }
    catch {
        Write-PCXLog $_.Exception.Message "ERROR"
        throw
    }
}
   

$ApplicationName = "APP Igor Pavlov 7zip 26.0.0"
$DeploymentTypeName =  "7-Zip 26.00 (x64 edition) - Windows Installer (*.msi file)"


Add-PCXCMApplicationWindows11Requirement `
    -ApplicationName $ApplicationName `
    -DeploymentTypeName $DeploymentTypeName #"MSI"


# Application Information
$ApplicationName = "APP Igor Pavlov 7zip 26.0.0"

$DeploymentTypeName = "7-Zip 26.00 (x64 edition) - Windows Installer (*.msi file)"

# Get Windows 11 platform
$Windows11Platforms = Get-CMSupportedPlatform | Where-Object {
    $_.DisplayText -eq "All Windows 11 (64-bit) Client"
}

# Create requirement rule
$RequirementRule = New-CMRequirementRuleOperatingSystemValue `
    -RuleOperator OneOf `
    -SupportedOperatingSystemPlatform $Windows11Platforms

# Add requirement to Deployment Type
Set-CMScriptDeploymentType `
    -ApplicationName $ApplicationName `
    -DeploymentTypeName $DeploymentTypeName `
    -AddRequirement $RequirementRule

    ############################

<#
 
# 1. Connect to SCCM PowerShell
# Make sure you are in the Configuration Manager site drive (e.g., PS XYZ:\>).

# 2. Get the Global Condition for Operating System
$gc = Get-CMGlobalCondition -Name "Operating System"

Get-CMSupportedPlatform -DisplayText "All Windows 11 (64-bit) Client"

Get-CMOperatingSystem 
Get-CMSupportedPlatform | Select-Object DisplayText

# 3. Create a Requirement Rule for Windows 11 (x64)
# Use the New-CMRequirementRuleOperatingSystemValue cmdlet to define the OS requirement.
$rule = New-CMRequirementRuleOperatingSystemValue `
    -InputObject $gc `
    -RuleOperator OneOf `
    -OperatingSystem (Get-CMOperatingSystem -Name "All Windows 11 (64-bit)")

# 4. Add the Requirement to Your Deployment Type
# If you already have a deployment type (e.g., MSI-based):
Set-CMMsiDeploymentType `
    -ApplicationName "MyApp" `
    -DeploymentTypeName "Install" `
    -AddRequirement $rule

# If it’s a script-based deployment type:
Set-CMScriptDeploymentType `
    -ApplicationName "MyApp" `
    -DeploymentTypeName "Install" `
    -AddRequirement $rule


    # Example

    cd XYZ:\

$gc = Get-CMGlobalCondition -Name "Operating System"
$os = Get-CMOperatingSystem -Name "All Windows 11 (64-bit)"
$rule = New-CMRequirementRuleOperatingSystemValue -InputObject $gc -RuleOperator OneOf -OperatingSystem $os

Set-CMMsiDeploymentType -ApplicationName "MyApp" -DeploymentTypeName "Install" -AddRequirement $rule

Set-CMMsiDeploymentType -ApplicationName "MyApp" -DeploymentTypeName "Install" -AddRequirement $rule

#>
    
# 1. Connect to SCCM PowerShell
# Make sure you are in the Configuration Manager site drive (e.g., PS XYZ:\>).

# 2. Get the Global Condition for Operating System
$gc = Get-CMGlobalCondition -Name "Operating System"

Get-CMSupportedPlatform -DisplayText "All Windows 11 (64-bit) Client"

Get-CMOperatingSystem 
Get-CMSupportedPlatform | Select-Object DisplayText

# 3. Create a Requirement Rule for Windows 11 (x64)
# Use the New-CMRequirementRuleOperatingSystemValue cmdlet to define the OS requirement.
$rule = New-CMRequirementRuleOperatingSystemValue `
    -InputObject $gc `
    -RuleOperator OneOf `
    -OperatingSystem (Get-CMSupportedPlatform -DisplayText "All Windows 11 (64-bit) Client")

# 4. Add the Requirement to Your Deployment Type
# If you already have a deployment type (e.g., MSI-based):
Set-CMMsiDeploymentType `
    -ApplicationName "MyApp" `
    -DeploymentTypeName "Install" `
    -AddRequirement $rule

# If it’s a script-based deployment type:
Set-CMScriptDeploymentType `
    -ApplicationName "MyApp" `
    -DeploymentTypeName "Install" `
    -AddRequirement $rule


    # Example

    cd XYZ:\

$gc = Get-CMGlobalCondition -Name "Operating System"
$os = Get-CMOperatingSystem -Name "All Windows 11 (64-bit)"
$rule = New-CMRequirementRuleOperatingSystemValue -InputObject $gc -RuleOperator OneOf -OperatingSystem $os

Set-CMMsiDeploymentType -ApplicationName "MyApp" -DeploymentTypeName "Install" -AddRequirement $rule

Set-CMMsiDeploymentType -ApplicationName "MyApp" -DeploymentTypeName "Install" -AddRequirement $rule

New-CMRequirementRuleOperatingSystemValue -

$ApplicationName = "APP Igor Pavlov 7zip 26.0.0"

$DeploymentTypeName = "7-Zip 26.00 (x64 edition) - Windows Installer (*.msi file)"

$myGC = Get-CMGlobalCondition -Name "Operating System" | Where-Object PlatformType -eq 1
$platformA = Get-CMConfigurationPlatform -Name "All Windows Server 2019 and higher (64-bit)" -Fast
$platformB = Get-CMConfigurationPlatform -Name "All Windows Server 2016 and higher (64-bit)" -Fast
$myRule = $myGC | New-CMRequirementRuleOperatingSystemValue -RuleOperator OneOf -Platform $platformA, $platformB
Set-CMScriptDeploymentType -ApplicationName "APP Igor Pavlov 7zip 26.0.0" -DeploymentTypeName "7-Zip 26.00 (x64 edition) - Windows Installer (*.msi file)" -AddRequirement $myRule


#----------------------------------------------

$myGC = Get-CMGlobalCondition -Name "Operating System" | Where-Object PlatformType -eq 1

$platformA = Get-CMConfigurationPlatform -Name "All Windows Server 2019 and higher (64-bit)" -Fast
$platformB = Get-CMConfigurationPlatform -Name "All Windows Server 2016 and higher (64-bit)" -Fast

$ruleA = New-CMRequirementRuleOperatingSystemValue -InputObject $myGC -RuleOperator OneOf -Platform $platformA
$ruleB = New-CMRequirementRuleOperatingSystemValue -InputObject $myGC -RuleOperator OneOf -Platform $platformB


Set-CMScriptDeploymentType `
    -ApplicationName "APP Igor Pavlov 7zip 26.0.0" `
    -DeploymentTypeName "7-Zip 26.00 (x64 edition) - Windows Installer (*.msi file)" `
    -AddRequirement $ruleA,$ruleB

#----------------------------------------------

$myGC = Get-CMGlobalCondition -Name "Operating System" | Where-Object PlatformType -eq 1
#$win11 = Get-CMConfigurationPlatform -Name "All Windows 11 (64-bit)" -Fast
$win11 = Get-CMConfigurationPlatform -LocalizedDisplayName "All Windows 8 Client (64-bit)" -Fast
#$win11 = Get-CMConfigurationPlatform -LocalizedDisplayName "All Windows 11 Professional/Enterprise and higher (64-bit)" -Fast


$ruleWin11 = New-CMRequirementRuleOperatingSystemValue -InputObject $myGC -RuleOperator OneOf -Platform $win11

Set-CMMsiDeploymentType `
    -ApplicationName "APP Igor Pavlov 7zip 26.0.0" `
    -DeploymentTypeName "7-Zip 26.00 (x64 edition) - Windows Installer (*.msi file)"
    -AddRequirement $ruleWin11

Set-CMScriptDeploymentType `
    -ApplicationName "APP Igor Pavlov 7zip 26.0.1 (SCRIPT Type)" `
    -DeploymentTypeName "APP Igor Pavlov 7zip 26.0.1 (SCRIPT Type) DT" `
    -AddRequirement $ruleWin11

Set-CMScriptDeploymentType `
    -ApplicationName "APP Igor Pavlov 7zip 26.0.0" `
    -DeploymentTypeName "7-Zip 26.00 (x64 edition) - Windows Installer (*.msi file)" `
    -AddRequirement $ruleWin11

$PCXCMConfigurationPlatform = Get-CMConfigurationPlatform -Fast | Select-Object LocalizedDisplayName, CI_UniqueID, ModelName
Get-CMConfigurationPlatform -Fast | Select-Object LocalizedDisplayName, CI_UniqueID, ModelName
