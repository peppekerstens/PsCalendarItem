function Convert-ScheduleToDateTime {
    <#
    .SYNOPSIS
        Converts any provided schedule to a list of datetime triggers
    .DESCRIPTION
        Long description
    .EXAMPLE
        PS C:\> <example usage>
        Explanation of what the example does
    .INPUTS
        Inputs (if any)
    .OUTPUTS
        Output (if any)
    .NOTES
        General notes
    #>
    [CmdletBinding()]
    [OutputType([psobject])]
    param(
        <# Any form of json to object:
        >any/everyday
        >single
        {
            "start": ["14:00"]
        }
        or
        {
            "end": ["20:00"]
        }
        or
        {
            "start": ["14:00"]
        }
        or
        {
            "end": ["20:00"]
        }

        >any/everyday
        >double
        {
            "start": ["14:00","19:00"],
            "end": ["20:00"]
        }

        >daysoftheweek
        [
            {
                "day" : ["fri",”sat”,”sun”],
                "end": ["20:00"]
            }
        ]

        >weekly
        [
            {
                "week": [1],
                "day" : ["th","f",”sat”,”sun”],
                "end": ["20:00"]
            }
        ]

        >monthly
        [
            {
                "day" : [1,-1],
                "end": ["20:00"]
            }
        ]

        >preference
        default preference is days over weeks over monthly

        >some combinations allowed
        >daily/monthly
        [
            {
                "day" : ["m","tu",1,-1],
                "start": ["*"]
            }
        ]
        >weekly/monthly
        [
            {
                "week": [1,-1],
                "day" : ["m","tu",1,-1],
                "end": ["*"]
            }
        ]         
        #>
        [psobject[]]$Schedule
        ,
        [datetime]$Reference = (Get-Date)
    )

    $ErrorActionPreference = 'Stop'
    $script:StartDateTimes = @()
    $script:EndDateTimes = @()
    $script:StartDateDays = @()
    $script:EndDateDays = @()
    $script:lastDayOfMonth = [DateTime]::DaysInMonth($Reference.Year, $Reference.Month)
    $script:lastWeekOfMonth = [math]::Ceiling($lastDayOfMonth.Day/7)
    Foreach ($sd in $Schedule){
        Write-Debug "Processing schedule item $($Schedule.IndexOf($sd))"
        #analyse parameters
        $daynumbers = @()
        $days = @()
        $weeknumbers = @()
        If (($sd.end -contains '*') -and ($sd.end.count -gt 1)){
            Write-Error "End item in schedule contains inconsistent items $($sd | Format-Table | Out-String)"
        }
        If  (($sd.start -contains '*') -and ($sd.start.count -gt 1)){
            Write-Error "Start item in schedule contains inconsistent items $($sd | Format-Table | Out-String)"
        }
        If (($sd.end -contains '*') -and ($sd.start -contains '*')){
            Write-Error "Both start and End items in schedule contain a wildcard. Not allowed. $($sd | Format-Table | Out-String)"
        }
        If ($sd.day){
            if (($sd.day -contains '*') -and ($sd.day.count -gt 1)){
                Write-Error "Day item in schedule contains inconsistent items $($sd | Format-Table | Out-String)"
            }
            #can either be a number(ofmonth) of a string(partofday)
            $daynumbers = ($sd.day|ForEach-Object{$_ -as [int]}).Where{$_ -ne $null}
            $days = $sd.day.where{$_ -notin $daynumbers}
        }
        If ($sd.week){
            $weeknumbers = $sd.week|ForEach-Object{$_ -as [int]}
            if (($weeknumbers | Foreach-Object{$_ -notin @(1,2,3,4,-1)}).Where{$_ -eq $true}){
                Write-Error "Week contains invalid value. $($sd | Format-Table | Out-String)"
            }
            if ($days.Count -lt 1){
                Write-Error "Week provided, but no day(ofweek) string. $($sd | Format-Table | Out-String)"
            }            
        }
        #iterate through options. processing 'wide' to 'narrow' in time (month, week (to)day). 
        If ($daynumbers){
            Write-Debug "Processing daynumbers"
            $StartDate = $Reference.AddMonths(-1)
            $EndDate = $Reference.AddMonths(1)
            $DateRange = $EndDate - $StartDate 
            For($DayCount=0;$DayCount -le $DateRange.TotalDays;$DayCount++){
                $CheckDate = $StartDate.AddDays($DayCount)
                $lastDayOfMonth = [DateTime]::DaysInMonth($CheckDate.Year, $CheckDate.Month)
                foreach ($daynumber in $daynumbers) {
                    #Write-Debug "Processing checkdate: $($CheckDate) daynumber $($daynumber), comparing to daynumber: $($CheckDate.Day)"
                    If ((($daynumber -eq -1) -and ($CheckDate.Day -eq $lastDayOfMonth)) -or ($CheckDate.Day -eq $DayNumber)){
                        DirtyCheckTimes -sd $sd
                    }
                }
            }
        }
        If ($weeknumbers){
            Write-Debug "Processing weeknumbers"
            #range to look is also a month. a schedule may be a single on-off scenario within certain weeks of month (rare)
            $StartDate = $Reference.AddMonths(-1)
            $EndDate = $Reference.AddMonths(1)
            $DateRange = $EndDate - $StartDate 
            For($DayCount=0;$DayCount -le $DateRange.TotalDays;$DayCount++){
                $CheckDate = $StartDate.AddDays($DayCount)
                $CheckWeek = [math]::Ceiling($CheckDate.Day/7)
                $lastDayOfMonth = [DateTime]::DaysInMonth($CheckDate.Year, $CheckDate.Month)
                $lastWeekOfMonth = [math]::Ceiling($lastDayOfMonth/7)
                foreach ($weeknumber in $weeknumbers) {
                    If ((($weeknumber -eq -1) -and ($lastWeekOfMonth -eq $CheckWeek)) -or ($weeknumber -eq $CheckWeek)){
                        DirtyCheckDays -Days $days -CheckDate $CheckDate -sd $sd
                    }
                }
            }
        }
        
        If ($days -and -not($sd.week)){
            Write-Debug "Processing days"
            $StartDate = $Reference.AddDays(-1)
            $EndDate = $Reference.AddDays(1)
            $DateRange = $EndDate - $StartDate 
            For($DayCount=0;$DayCount -le $DateRange.TotalDays;$DayCount++){
                $CheckDate = $StartDate.AddDays($DayCount)
                DirtyCheckDays -Days $days -CheckDate $CheckDate -sd $sd
            }
        }

        #For simplest type, when no other params are given but start and/or End
        If (-not($sd.day) -and -not($sd.week)){
            Write-Debug "Processing times"
            $StartDate = $Reference.AddDays(-1)
            $EndDate = $Reference.AddDays(1)
            $DateRange = $EndDate - $StartDate 
            For($DayCount=0;$DayCount -le $DateRange.TotalDays;$DayCount++){
                $CheckDate = $StartDate.AddDays($DayCount)
                $days = $CheckDate.DayOfWeek #just emulate $days -> working towards code refactoring
                DirtyCheckDays -Days $days -CheckDate $CheckDate -sd $sd
            }
        }
    }

    #Final check on dates.
    $inconsistentTicks = Compare-Object -ReferenceObject $StartDateTimes -DifferenceObject $EndDateTimes -Property Ticks -IncludeEqual -ExcludeDifferent
    If ($inconsistentTicks){
        Write-Error "Combination of schedules results in having overlapping start and End times for these dates. $($inconsistentTicks | ForEach-Object {[datetime]($_.Ticks)} | Format-Table Date,DayOfWeek,Hour,Minute| Out-String)"
    }
    $inconsistentDays = Compare-Object -ReferenceObject $EndDateDays -DifferenceObject $StartDateDays -Property Date -IncludeEqual -ExcludeDifferent
    If ($inconsistentDays){
        Write-Error "Combination of schedules results in having overlapping start and End days for these dates. $($inconsistentDays.Date | Format-Table | Out-String)"
    }
    #Some grooming. Wildcards and/or days have preference over hours.
    Foreach ($EndDateDay in $EndDateDays){
        $EndDateTimes = $EndDateTimes.Where{$_.Date -ne $EndDateDay}
        $EndDateTimes += $EndDateDay
        $ConflictStartTimes = $StartDateTimes.Where{$_.Date -eq $EndDateDay}
        Foreach ($ConflictStartTime in $ConflictStartTimes){
            Write-Error "Conflicting Start time $($ConflictStartTime) and wildcard End found for date $($EndDateDay)"
        }
    } 
    #$overlappingEndDays = (Compare-Object -ReferenceObject $EndDateDays -DifferenceObject $EndDateTimes -Property Date -IncludeEqual -ExcludeDifferent).Date | Sort-Object -Unique
    #foreach ($overlappingEndDay in $overlappingEndDays){
    #    $EndtDateTimes = $EndtDateTimes.Where{$_.Date -ne $overlappingEndDay}
    #    $EndtDateTimes += $overlappingEndDay
    #}
    #$overlappingStartDays = (Compare-Object -ReferenceObject $StartDateDays -DifferenceObject $StartDateTimes -Property Date -IncludeEqual -ExcludeDifferent).Date | Sort-Object -Unique
    #foreach ($overlappingStartDay in $overlappingStartDays){
    #    $StartDateTimes = $StartDateTimes.Where{$_.Date -ne $overlappingStartDay}
    #    $StartDateTimes += $overlappingStartDay
    #}
    Foreach ($StartDateDay in $StartDateDays){
        $StartDateTimes = $StartDateTimes.Where{$_.Date -ne $StartDateDay}
        $StartDateTimes += $StartDateDay
        $ConflictEndTimes = $EndDateTimes.Where{$_.Date -eq $StartDateDay}
        Foreach ($ConflictEndTime in $ConflictEndTimes){
            Write-Error "Conflicting End time $($ConflictEndTime) and wildcard Start found for date $($StartDateDay)"
        }
    } 
    [PSCustomObject]@{
        StartDateTimes = $StartDateTimes
        EndDateTimes = $EndDateTimes
    }
}



function DirtyCheckDays{
    [CmdletBinding()]
    [OutputType([psobject])]
    param(
        [array]$days
        ,
        [datetime]$CheckDate
        ,
        [psobject]$sd
    )
    foreach ($day in $days){
        $DayOfWeek = Get-DayOfWeek $day
        If ($DayOfWeek -contains $CheckDate.DayOfWeek){ 
            DirtyCheckTimes -sd $sd
        }
    }
}

function DirtyCheckTimes{
    [CmdletBinding()]
    param(
        [psobject]$sd
    )
    Foreach ($End in $sd.End){
        Write-Debug "Processing end time $($End)"
        If ($End -eq '*'){
            $script:endDateDays += $CheckDate.Date
            Write-Debug "Added $($CheckDate.Date) to endDateDays"
        }Else{
            $Endobj = [datetime]$End
            $script:endDateTimes += $CheckDate.Date.AddHours($EndObj.Hour).AddMinutes($EndObj.Minute)
            Write-Debug "Added $($CheckDate.Date.AddHours($EndObj.Hour).AddMinutes($EndObj.Minute)) to endDateTimes"
        }
    }

    Foreach ($Start in $sd.Start){
        Write-Debug "Processing Start time $($Start)"
        If ($Start -eq '*'){
            $script:StartDateDays += $CheckDate.Date
            Write-Debug "Added $($CheckDate.Date) to StartDateDays"
        }Else{
            $StartObj = [datetime]$start
            $script:StartDateTimes += $CheckDate.Date.AddHours($StartObj.Hour).AddMinutes($StartObj.Minute)
            Write-Debug "Added $($CheckDate.Date.AddHours($StartObj.Hour).AddMinutes($StartObj.Minute)) to StartDateTimes"
        }
    }
}