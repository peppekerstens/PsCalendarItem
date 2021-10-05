function Assert-ScheduledTrigger {
    <#  
        .SYNOPSIS   
            Asserts if provided trigger datetime(s) falls inside or outside the datetime range created by reference and timespan.
        
        .DESCRIPTION   
            Accepts a single or series of trigger datetime(s). Checks if provided datetimes are same as reference datetime.
            If timespan is also provided, it checks if datetimes falls within the resulting datetime range created by reference and timespan.

        .PARAMETER DateTime
            One or more datetime objects, or values which can implicitly and uniquely converted to datetime objects.
        
        .PARAMETER TimeSpan 
            TimeSpan object. If provided, check datetime range is result of Reference +- TimeSpan/2
        
        .PARAMETER Reference
            The datetime moment to reference. Normally/default is current datetime. 

        .EXAMPLE  
            Assert-ScheduledTrigger -DateTime '13:00' -Reference '13:00'

            returns $true

        .EXAMPLE  
            Assert-ScheduledTrigger -DateTime '13:10' -Reference '13:00'

            returns $false

        .EXAMPLE  
            Assert-ScheduledTrigger -DateTime '13:10' -TimeSpan ([timespan]::FromMinutes(30)) -Reference '13:00'

            returns $true

        .EXAMPLE  
            Assert-ScheduledTrigger -DateTime '13:40' -TimeSpan ([timespan]::FromMinutes(30)) -Reference '13:00'

            returns $false
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory)]
        [datetime[]]$DateTime
        ,
        [timespan]$TimeSpan
        ,
        [datetime]$Reference = (Get-Date)
    )
  
    $Divider = [timespan]::new(0)
    If ($TimeSpan){
        #$TimeSpan/2 is supported PS6 or higher
        $Divider = [timespan]::new($TimeSpan.Ticks / 2)
    }
    $StartDateTime = $Reference - $Divider
    $EndDateTime = $Reference + $Divider

    ($DateTime | Where-Object {($_.Ticks -gt $StartDateTime.Ticks) -and ($_.Ticks -lt $EndDateTime.Ticks)}) -and $true
}