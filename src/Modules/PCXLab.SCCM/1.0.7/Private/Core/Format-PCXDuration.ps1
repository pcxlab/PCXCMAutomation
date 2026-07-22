function Format-PCXDuration {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateRange(0, [double]::MaxValue)]
        [double]$TotalSeconds
    )

    function Get-UnitText {
        param(
            [int]$Value,
            [string]$Singular,
            [string]$Plural
        )

        if ($Value -eq 1) {
            return "$Value $Singular"
        }

        return "$Value $Plural"
    }

    # Milliseconds
    if ($TotalSeconds -lt 1) {

        $Milliseconds = [math]::Round($TotalSeconds * 1000)

        if ($Milliseconds -lt 1) {
            return "< 1 ms"
        }

        return "$Milliseconds ms"
    }

    # Round only after millisecond handling
    $TotalSeconds = [math]::Round($TotalSeconds, 2)

    # Seconds
    if ($TotalSeconds -lt 60) {
        return "{0:N2} sec" -f $TotalSeconds
    }

    $TimeSpan = [TimeSpan]::FromSeconds($TotalSeconds)

    # Minutes
    if ($TimeSpan.TotalHours -lt 1) {

        $Minutes = $TimeSpan.Minutes
        $Seconds = $TimeSpan.Seconds

        if ($Seconds -eq 0) {
            return "$Minutes min"
        }

        return "$Minutes min $Seconds sec"
    }

    # Hours
    if ($TimeSpan.TotalDays -lt 1) {

        $Hours = [math]::Floor($TimeSpan.TotalHours)
        $Minutes = $TimeSpan.Minutes

        if ($Minutes -eq 0) {
            return "$Hours hr"
        }

        return "$Hours hr $Minutes min"
    }

    # Days
    if ($TimeSpan.TotalDays -lt 30) {

        $Days = [math]::Floor($TimeSpan.TotalDays)
        $Hours = $TimeSpan.Hours

        if ($Hours -eq 0) {
            return Get-UnitText -Value $Days -Singular "day" -Plural "days"
        }

        return "$(Get-UnitText -Value $Days -Singular 'day' -Plural 'days') $Hours hr"
    }

    # Months (< 12)
    $Months = [math]::Floor($TimeSpan.TotalDays / 30)

    if ($Months -lt 12) {

        $RemainingDays = [math]::Floor($TimeSpan.TotalDays % 30)

        if ($RemainingDays -eq 0) {
            return Get-UnitText -Value $Months -Singular "month" -Plural "months"
        }

        return "$(Get-UnitText -Value $Months -Singular 'month' -Plural 'months') $RemainingDays day"
    }

    # Years
    $Years = [math]::Floor($TimeSpan.TotalDays / 365)
    $RemainingMonths = [math]::Floor(($TimeSpan.TotalDays % 365) / 30)

    if ($RemainingMonths -eq 0) {
        return Get-UnitText -Value $Years -Singular "year" -Plural "years"
    }

    return "$(Get-UnitText -Value $Years -Singular 'year' -Plural 'years') $RemainingMonths month"
}