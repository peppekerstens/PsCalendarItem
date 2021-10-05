function Convert-DayOfMonthToDate
{ 
    <#  
    .SYNOPSIS   
        Converts provided DayOfWeek and Week number to a valid date for reference
    
    .PARAMETER Day 
        Provide the day of the week. Must be part of the English full name format. 
    
    .PARAMETER Number
        The instance of the series. So second sunday of the month to check (provide value 2)
    
    .PARAMETER Reference
        Reference datetime value. Defaults to current date/time. Must be of type [datetime]
       
    .EXAMPLE  
        Convert-DayOfMonthToDate -Day 'Sun' -Number 2 -Reference 
    
    .EXAMPLE  
        Convert-DayOfWeekNumberToDate June 2015
    #> 
    
    param(
        #[Parameter(Mandatory)]
        [ValidateSet(1-31,-1)]
        [int]$DayNumber
        ,
        [Parameter(Mandatory)]
        [string]$Day
        ,
        [Parameter(Mandatory)]
        [ValidateSet(1,2,3,4,-1)]
        [int]$Number
        ,
        [datetime]$Reference = (Get-Date)
    ) 

    $firstdayofmonth = Get-Date -Date $Reference -Day 1
    #$firstdayofmonth = [datetime]"$($Month)/1/$($Year)"
    $fullnameday = @(Get-DayOfWeek $day)
    If (($fullnameday.count -eq 0) -or ($fullnameday.count -gt 1)){
        Throw "cannot convert parameter Day value $($day) to a unique or valid day of the week!"
    }
    If ($Number -eq -1){
        $nr = 0
    }Else{
        $nr = $Number
    }
    (0..30 | Foreach-Object {$firstdayofmonth.adddays($_) } | Where-Object {$_.dayofweek -eq $fullnameday})[$nr-1]
}