function New-PCXReportObject {

    [CmdletBinding()]
    param(

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$ApplicationName,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Requirement,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Status,

        [Parameter(Mandatory = $false)]
        [string]$Message,

        [Parameter(Mandatory = $false)]
        $Application
    )

    # ==========================================================
    # AUTO-GENERATE MESSAGE IF NOT PROVIDED
    # ==========================================================

    if (-not $PSBoundParameters.ContainsKey('Message')) {

        switch ($Status) {

            "Updated" {
                $Message = "Success"
            }

            "AlreadyExists" {
                $Message = "Requirement already exists"
            }

            "Skipped" {
                $Message = "Requirement creation not allowed"
            }

            "Failed" {
                $Message = "Failed"
            }

            default {
                $Message = $Status
            }
        }
    }

    # ==========================================================
    # HANDLE NULL APPLICATION SAFELY
    # ==========================================================

    if ($null -eq $Application) {

        return [PSCustomObject]@{
            ApplicationName  = $ApplicationName
            Requirement      = $Requirement
            Status           = $Status
            Message          = $Message
            Timestamp        = Get-Date
            PackageID        = $null
            CIVersion        = $null
            SourceSite       = $null
            CreatedDate      = $null
            CreatedBy        = $null
            DateLastModified = $null
            LastModifiedBy   = $null
        }
    }

    # ==========================================================
    # STANDARD SUCCESS OBJECT
    # ==========================================================

    return [PSCustomObject]@{
        ApplicationName  = $ApplicationName
        Requirement      = $Requirement
        Status           = $Status
        Message          = $Message
        Timestamp        = Get-Date
        PackageID        = $Application.PackageID
        CIVersion        = $Application.CIVersion
        SourceSite       = $Application.SourceSite
        CreatedDate      = $Application.DateCreated
        CreatedBy        = $Application.CreatedBy
        DateLastModified = $Application.DateLastModified
        LastModifiedBy   = $Application.LastModifiedBy
    }
}


