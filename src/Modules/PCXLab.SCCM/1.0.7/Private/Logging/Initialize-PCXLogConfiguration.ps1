function Initialize-PCXLogConfiguration {

    $Global:PCXLogConfiguration = @{

        Company            = "PCXLab"      # Framework vendor
        Organization       = "PCXLab"      # SCCM root folder
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
        "Create-PCXCMPackage"                                      = "Create Package"
        "New-PCXCMPackage"                                         = "Create SCCM Package"

        "Move-PCXCMPackageToFolder"                                = "Move Package"

        # Applications
        "Create-PCXCMApplication"                                  = "Create Application"
        "New-PCXCMApplication"                                     = "Create SCCM Application"

        "New-PCXCMApplicationDeploymentType"                       = "Create SCCM Deployment Type"

        "New-PCXCMApplicationDetectionClause"                      = "Create Detection Clause"

        "Add-PCXCMApplicationOSRequirement"                        = "Add OS Requirement"
        "Add-PCXCMApplicationOSRequirementFromCSV"                 = "Bulk Add OS Requirements"

        "Add-PCXCMApplicationOSRequirementToDeploymentType"        = "Add OS Requirement To Deployment Type"
        "Add-PCXCMApplicationOSRequirementToXML"                   = "Add OS Requirement To XML"

        "Add-PCXCMApplicationMemoryRequirementToDeploymentType"    = "Add Memory Requirement"
        "Add-PCXCMApplicationDiskSpaceRequirementToDeploymentType" = "Add Disk Space Requirement"

        "New-PCXCMApplicationDeployment"                           = "Create SCCM Application Deployment"

        "Get-PCXCMApplicationXML"                                  = "Get Application XML"
        "Save-PCXCMApplicationXML"                                 = "Save Application XML"

        "Get-PCXCMApplication"                                     = "Get Application"

        "Get-PCXCMApplicationOSRequirementOperand"                 = "Get OS Requirement Operand"
        "New-PCXCMApplicationOSRequirementRule"                    = "Create OS Requirement Rule"
        "Test-PCXCMApplicationOSRequirementExists"                 = "Test OS Requirement"

        "Import-PCXCMApplicationList"                              = "Import Application List"

        # SCCM Connection / Content
        "Connect-PCXCMSite"                                        = "Connect SCCM Site"
        "Start-PCXCMContentDistribution"                           = "Distribute Content"

        # Collections
        "New-PCXCMDeploymentDeviceCollections"                     = "Create Collections"

        "New-PCXCMDeviceCollection"                                = "Create SCCM Device Collection"
        "New-PCXCMDeviceCollectionInFolder"                        = "Create Collection In Folder"

        "Add-PCXCMCollectionInclusion"                             = "Add Collection Inclusion"
        "Add-PCXCMCollectionExclusion"                             = "Add Collection Exclusion"
        "Add-PCXCMCollectionQueryRule"                             = "Add Collection Query Rule"

        "Set-PCXCMDeploymentCollectionRules"                       = "Configure Collection Rules"

        "Get-PCXCMDeviceCollection"                                = "Get Device Collection"
        "Ensure-PCXCMDeviceCollection"                             = "Ensure Device Collection"

        # Folders
        "New-PCXCMFolder"                                          = "Create Folder"

        "Move-PCXCMObject"                                         = "Move Object"
        "Move-PCXCMApplicationToFolder"                            = "Move Application"
        "Move-PCXCMCollectionsToFolder"                            = "Move Collections"

        # Paths
        "Test-PCXPackagePath"                                      = "Validate Package Path"
        "Resolve-PCXCMPath"                                        = "Resolve CM Path"
    }

    # Operation stack
    $Global:PCXOperationStack = New-Object System.Collections.Stack
}


