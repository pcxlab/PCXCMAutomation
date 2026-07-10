function Get-PCXCMDescriptionInformation {

    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [string]$Creator = $env:USERNAME,
        [string]$Reviewer,
        [string]$RequestNumber,
        [string]$Comment
    )

    try {
        # Read settings
        $MaximumCharacters = Get-PCXCMSetting -Name "DescriptionSettings.MaximumLength"
        if (-not $MaximumCharacters) {
            $MaximumCharacters = 127
        }

        $DateFormat = Get-PCXCMSetting -Name "DescriptionSettings.DateFormat"
        if ([string]::IsNullOrWhiteSpace($DateFormat)) {
            $DateFormat = "dd-MMM-yy HH:mm"
        }

        # Normalize input
        $Creator = "$Creator".Trim()
        $Reviewer = "$Reviewer".Trim()
        $RequestNumber = "$RequestNumber".Trim()

        if ($null -ne $Comment) {
            $Comment = "$Comment".Trim()
            $Comment = $Comment -replace '\r?\n', ' '
        }
        else {
            $Comment = ""
        }

        # Generate timestamp
        $Date = Get-Date -Format $DateFormat

        # Description layout
        $Layout = Get-PCXCMSetting -Name "DescriptionSettings.Layout"

        if ([string]::IsNullOrWhiteSpace($Layout)) {
            $Layout = "SingleLine"
        }

        switch ($Layout.ToLower()) {
            "multiline" {
                $Separator = [Environment]::NewLine
            }
            "singleline" {
                $Separator = Get-PCXCMSetting -Name "DescriptionSettings.Separator"

                if ([string]::IsNullOrWhiteSpace($Separator)) {
                    $Separator = " "
                }
            }

            default {
                throw "Invalid DescriptionSettings.Layout '$Layout'. Valid values are 'SingleLine' and 'MultiLine'."
            }
        }

        # Build description prefix
        $Lines = [System.Collections.Generic.List[string]]::new()

        if ($Creator) {
            $Lines.Add($Creator)
        }

        if ($Reviewer) {
            $Lines.Add($Reviewer)
        }

        if ($RequestNumber) {
            $Lines.Add($RequestNumber)
        }

        $Lines.Add($Date)

        $Prefix = $Lines -join $Separator

        if ($Prefix.Length -gt 0) {
            $Prefix += $Separator
        }

        $PrefixLength = $Prefix.Length
        $AllowedCommentLength = [Math]::Max(0, $MaximumCharacters - $PrefixLength)

        # Trim comment if required
        if ($Comment.Length -gt $AllowedCommentLength) {
            $Comment = $Comment.Substring(0, $AllowedCommentLength)
        }

        if ($Comment) {
            $Lines.Add($Comment)
        }

        $Description = $Lines -join $Separator
        $DescriptionLength = $Description.Length

        $Result = [PSCustomObject]@{
            Description          = $Description
            DescriptionLines     = $Lines.ToArray()

            Creator              = $Creator
            Reviewer             = $Reviewer
            RequestNumber        = $RequestNumber
            Date                 = $Date
            Comment              = $Comment

            DescriptionLength    = $DescriptionLength
            PrefixLength         = $PrefixLength
            MaximumCharacters    = $MaximumCharacters
            RemainingCharacters  = $MaximumCharacters - $DescriptionLength
            AllowedCommentLength = $AllowedCommentLength
            IsValid              = ($DescriptionLength -le $MaximumCharacters)
        }

        $Result.PSObject.TypeNames.Insert(0, 'PCXLab.SCCM.DescriptionInformation')

        return $Result
    }
    catch {
        throw
    }
}