function Initialize-PCXLogConfiguration {

    $Global:PCXLogConfiguration = @{

        FrameworkName      = "PCXLab Automation Framework"
        Website            = "www.pcxlab.com"

        ShowBranding       = $true

        StartText          = "START"

        UseFriendlyNames   = $true

        TerminalAppearance = @{

            # Future use
            #EnableCustomColors = $false
            EnableCustomColors = $true

            InfoColor          = "White"
            WarningColor       = "Yellow"
            ErrorColor         = "Red"
            DebugColor         = "Cyan"

            StartColor         = "Magenta"
            SuccessColor       = "Green"
            FailedColor        = "Red"
        }
    }

    $Global:PCXOperationNames = @{

        # Packages
        "Create-PCXCMPackage"                         = "Create Package"
        "Move-PCXCMPackageToFolder"                   = "Move Package"
        "New-PCXCMPackage"                            = "Create Package"

        # Applications
        "Create-PCXCMApplication"                     = "Create Application"
        "New-PCXCMApplication"                        = "Create Application"
        "New-PCXDetectionClause"                      = "Create Detection Clause"
        "New-PCXCMApplicationDeployment"              = "Create Application Deployment"
        "New-PCXCMApplicationDeploymentType"          = "Create Deployment Type"
        "Add-PCXCMApplicationOSRequirement"           = "Add OS Requirement"
        "Add-PCXCMApplicationOSRequirementFromCSV"    = "Bulk Add OS Requirements"
        "Get-PCXApplicationXML"                       = "Get Application XML"
        "Get-PCXCMApplication"                        = "Get Application"
        "Get-PCXOSRequirementOperand"                 = "Get OS Requirement Operand"
        "Import-PCXApplicationList"                   = "Import Application List"
        "New-PCXOSRequirementRule"                    = "Create OS Requirement Rule"
        "Save-PCXApplicationXML"                      = "Save Application XML"
        "Test-PCXOSRequirementExists"                 = "Test OS Requirement"
        "Add-PCXOSRequirementToDeploymentType"        = "Add OS Requirement To Deployment Type"
        "Add-PCXOSRequirementToXML"                   = "Add OS Requirement To XML"
        "Add-PCXMemoryRequirementToDeploymentType"    = "Add Memory Requirement"
        "Add-PCXDiskSpaceRequirementToDeploymentType" = "Add Disk Space Requirement"

        # SCCM
        "Connect-PCXCMSite"                           = "Connect SCCM Site"
        "Start-PCXCMContentDistribution"              = "Distribute Content"

        # Collections
        "New-PCXCollections"                          = "Create Collections"
        "Set-PCXCollectionRules"                      = "Configure Collection Rules"
        "New-PCXCMDeviceCollection"                   = "Create Device Collection"
        "New-PCXCMDeviceCollectionInFolder"           = "Create Collection In Folder"
        "Add-PCXCMCollectionExclusion"                = "Add Collection Exclusion"
        "Add-PCXCMCollectionInclusion"                = "Add Collection Inclusion"
        "Add-PCXCMCollectionQueryRule"                = "Add Collection Query Rule"
        "Get-PCXCMDeviceCollection"                   = "Get Device Collection"
        "Ensure-PCXCMDeviceCollection"                = "Ensure Device Collection"

        # Folders
        "New-PCXCMFolder"                             = "Create Folder"
        "Move-PCXCMObject"                            = "Move Object"
        "Move-PCXCMApplicationToFolder"               = "Move Application"
        "Move-PCXCMCollectionsToFolder"               = "Move Collections"

        # Paths
        "Test-PCXPackagePath"                         = "Validate Package Path"
        "Resolve-PCXCMPath"                           = "Resolve CM Path"
    }

    # Operation stack
    $Global:PCXOperationStack = New-Object System.Collections.Stack
}

