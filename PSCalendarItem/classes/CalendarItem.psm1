class Calendar {
    $cultureInfo = [System.Globalization.CultureInfo]::CurrentCulture
    [System.TimeZoneInfo]$timeZone
}

class CalendarItem {
    #Properties
    #UTC time!
    [ValidateNotNullOrEmpty()]
    [datetime]$startDateTime

    [datetime]$endDateTime

    [bool]$allDay

    #$effe = New-ScheduledTaskTrigger -at 20:00 -Daily -DaysInterval 2     
    [Microsoft.Management.Infrastructure.CimInstance]$repeat

    [string]$title

    [string]$notes

    # Constructors
    CalendarItem([datetime]$startDateTime,[datetime]$endDateTime)
    {
        $this.startDateTime = $startDateTime
        $this.endDateTime = $endDateTime
        $this.timeZone = Get-TimeZone
    }

    # Methods
    #Mock()
    #{
    #    $this.PowerState = Get-Random @('VM running','VM deallocated')
    #    $this.HardwareProfile = 'Standard_E4as_v4'
    #}

    [string]ToString()
    {
        $titleString = [string]::Empty
        If ($this.title){
            $titleString = " - $($this.title)"
        }
        #https://devblogs.microsoft.com/scripting/use-culture-information-in-powershell-to-format-dates/
        #Could just use Get-Culture instead of [System.Globalization.CultureInfo]::CurrentCulture
        $DateTimeDisplayPattern = [System.Globalization.CultureInfo]::CurrentCulture.DateTimeFormat.UniversalSortableDateTimePattern
        $startDateTimeString = Get-Date -Date $this.startDateTime -Format $DateTimeDisplayPattern
        $endDateTimeString = Get-Date -Date $this.endDateTime -Format $DateTimeDisplayPattern
        return "$($startDateTimeString) - $($endDateTimeString)$($titleString)"
    }
}


class Trigger {
    #extended version of 
    #$effe = New-ScheduledTaskTrigger -at 20:00 -Daily -DaysInterval 2 
    [bool]$Enabled

    [datetime]$End

    [interval]$Interval

    [int]$Repetition

    [timespan]$Delay
}

class Interval {
    #Properties
    [timespan]$TimeSpan 

    [ValidateRange(0-364,-1)]
    [int]$Day
    
    [ValidateRange(0-52,-1)]
    [int]$Week

    [ValidateSet('W','Week','M','Month','Y','Year')]
    [string]$Type

    # Constructors
    Interval($Type='Year')
    {
        #$this.startDateTime = $startDateTime
        #$this.endDateTime = $endDateTime
        #$this.timeZone = Get-TimeZone
    }
}

class Range {
    #Properties
    [datetime]$Begin

    [datetime]$End

    [bool]$Count

    # Constructors
    Range($Begin)
    {
        $this.Begin = $Begin
        $this.End = [System.Globalization.CultureInfo]::CurrentCulture.Calendar.MaxSupportedDateTime
        $this.Count = $false
    }

    Range($Begin,$End,$Count=$false)
    {
        $this.Begin = $Begin
        $this.End = $End
        $this.Count = $Count
    }
}