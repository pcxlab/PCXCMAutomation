$myGC = Get-CMGlobalCondition -Name "Operating System" | Where-Object PlatformType -eq 1
#$OSPlatform = Get-CMConfigurationPlatform -Name "All Windows 11 (64-bit)" -Fast
#$OSPlatform = Get-CMConfigurationPlatform -LocalizedDisplayName "All Windows 8 Client (64-bit)" -Fast
$OSPlatform = Get-CMConfigurationPlatform -LocalizedDisplayName "All Windows 11 Professional/Enterprise and higher (64-bit)" -Fast

$RequirementRule = New-CMRequirementRuleOperatingSystemValue -InputObject $myGC -RuleOperator OneOf -Platform $OSPlatform 

Set-CMScriptDeploymentType `
    -ApplicationName "APP Igor Pavlov 7zip 26.0.1 (SCRIPT Type)" `
    -DeploymentTypeName "APP Igor Pavlov 7zip 26.0.1 (SCRIPT Type) DT" `
    -AddRequirement $RequirementRule

