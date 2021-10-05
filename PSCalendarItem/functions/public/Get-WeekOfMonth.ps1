function Get-WeekNumber
{ 
    <#  
    .SYNOPSIS   
        Converts provided DayOfWeek and Week number to a valid date for reference
       
    .PARAMETER Reference
        Reference datetime value. Defaults to current date/time. Must be of type [datetime]
       
    .EXAMPLE  
        Get-WeekOfMonth  
    
    .EXAMPLE  
        Get-WeekOfMonth June 2015
    #> 
    
    param(
        [datetime]$DateTime = (Get-Date)
        ,
        [switch]$Month
    ) 

    $cultureInfo = [System.Globalization.CultureInfo]::CurrentCulture
    $DaysInMonth = $cultureInfo.Calendar.GetDaysInMonth($DateTime.Year,$DateTime.Month)
    If ($Month){
        $cultureInfo.Calendar.GetWeekOfYear($DateTime,$cultureInfo.DateTimeFormat.CalendarWeekRule,$cultureInfo.DateTimeFormat.FirstDayOfWeek)
    }Else{
        $cultureInfo.Calendar.GetWeekOfYear($DateTime,$cultureInfo.DateTimeFormat.CalendarWeekRule,$cultureInfo.DateTimeFormat.FirstDayOfWeek)
    }
}