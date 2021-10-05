function Convert-DayOfWeekNumberToDate
{ 
    <#  
    .SYNOPSIS   
        Converts provided DayOfWeek and Week number to a valid date for reference
    
    .PARAMETER DayOfWeek 
        Provide the day of the week. Must be part of the English full name format. 
    
    .PARAMETER Week
        The week number of the month to check
    
    .PARAMETER Reference
        Reference datetime value. Defaults to current date/time. Must be of type [datetime]
       
    .EXAMPLE  
        Convert-DayOfWeekNumberToDate -Week 1 -Reference 
    
    .EXAMPLE  
        Convert-DayOfWeekNumberToDate June 2015
    #> 
    
    param(
        [Parameter(Mandatory)]
        [string]$Day
        ,
        [Parameter(Mandatory)]
        [ValidateSet(1,2,3,4,5,-1)]
        [int]$Week
        ,
        [datetime]$Reference = (Get-Date)
        #,
        #[ValidateScript( {Get-Date -month $_} )]
        #[string]$Month = (Get-Date).month
        #,
        #[ValidateScript( {Get-Date -Year $_} )]
        #[int]$Year = (Get-Date).year
    ) 

    $firstdayofmonth = Get-Date -Date $Reference -Day 1
    #$firstdayofmonth = [datetime]"$($Month)/1/$($Year)"
    $dayOfWeek = @(Get-DayOfWeek $day)
    If (($dayOfWeek.count -eq 0) -or ($dayOfWeek.count -gt 1)){
        Throw "cannot convert parameter DayOfWeek value $($dayk) to a unique or valid day of the week!"
    }
    If ($Week -eq -1){
        $wk = 0
    }Else{
        $wk = $Week
    }
    (0..30 | Foreach-Object {$firstdayofmonth.adddays($_) } | Where-Object {$_.dayofweek -eq $dayOfWeek})[$wk-1]
}