function Get-CalendarEvent {
    <#
    .SYNOPSIS
    Gets all event within a calendar object based on provided time reference.

    .DESCRIPTION

    [CAUTION]
    Assumes that there IS a start and an end time provided for each event. May result in less predictable 
    
    .PARAMETER Schedule

    .PARAMETER Reference
    The reference time to check against. Results in an 
    .EXAMPLE
    #>

    param(
        [psobject[]]$Schedule
        ,
        [datetime]$Reference = (Get-Date)
    )

    process {
        $Schedule | ForEach-Object {
            $DateTimes = Convert-ScheduleToDateTime -Schedule $_ -Reference $Reference
            If (Assert-ScheduledEvent -Start $DateTimes.StartDateTimes -End $DateTimes.EndDateTimes -Reference $Reference){$_}
        }
    }
}