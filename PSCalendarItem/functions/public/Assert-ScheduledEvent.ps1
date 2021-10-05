function Assert-ScheduledEvent {
    <#  
        .SYNOPSIS   
            Asserts if reference datetime falls inside or outside provided datetime ranges.
        
        .DESCRIPTION   
            Asserts if reference datetime falls inside or outside provided datetime ranges. 
            
            When only start parameter value is provided, logic assumes $false state for time before begin time(s), scope is only the current (reference) day
            When only End parameter value is provided, logic assumes $true state for time before (first) end time, scope is only the current (reference) day

        .PARAMETER Start
            One or more beginning datetime objects.
        
        .PARAMETER End
            One or more ending datetime objects.
        
        .PARAMETER Reference
            The datetime moment to reference. Normally/default is current datetime. 

        .EXAMPLE  
            Assert-ScheduledEvent -Start '07:00' -End '17:00' -Reference '13:00'

            returns $true

        .EXAMPLE  
            Assert-ScheduledEvent -Start '07:00' -End '17:00' -Reference '05:00'

            returns $false
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [datetime[]]$start
        ,
        [datetime[]]$End
        ,
        [datetime]$Reference = (Get-Date)
    )
  
    If (!($PSBoundParameters.ContainsKey('Start')) -or (!($PSBoundParameters.ContainsKey('End')))){
        Write-Warning -Message "Provide Start and End parameter for consistent results. Otherwise logic makes assumptions!"
    }

    $LatestStartTime = $null
    If ($start){
        $LatestStartTime = ($start | Where-Object {$_.Ticks -le $Reference.Ticks} | Measure-Object -Maximum).Maximum
        If ($null -eq $LatestStartTime){
            $LatestStartTime = ($start | Where-Object {$_.Ticks -gt $Reference.Ticks} | Measure-Object -Minimum).Minimum
        }
        If ($null -eq $LatestStartTime){
            $LatestStartTime = ($start | Measure-Object -Minimum).Minimum
        }
    }
    If ($End){
        If ($LatestStartTime){
            $NextEndTime = ($End | Where-Object {$_.Ticks -ge $LatestStartTime.Ticks} | Measure-Object -Minimum).Minimum
        }Else{
            $NextEndTime = ($End | Where-Object {$_.Ticks -lt $Reference.Ticks} | Measure-Object -Maximum).Maximum 
        }
        If ($null -eq $NextEndTime){
            $NextEndTime = ($End | Where-Object {$_.Ticks -ge $Reference.Ticks} | Measure-Object -Minimum).Minimum
        }
        If ($null -eq $NextEndTime){
            $NextEndTime = ($End | Measure-Object -Maximum).Maximum
        }
    }

    If ($PSBoundParameters.ContainsKey('Start') -and $PSBoundParameters.ContainsKey('End')){
        $ShouldStart = $Reference -gt $LatestStartTime
        $ShouldEnd = $Reference -gt $NextEndTime
        If ($LatestStartTime -eq $NextEndTime){
            return $false
        }
        If ($LatestStartTime -le $NextEndTime){
            return ($ShouldStart -xor $ShouldEnd)
        }Else{
            return -not ($ShouldStart -xor $ShouldEnd)
        } 
    }
    ElseIf ($PSBoundParameters.ContainsKey('Start')){
        return ($Reference -ge $LatestStartTime)
    }
    ElseIf ($PSBoundParameters.ContainsKey('End')){
        return ($Reference -le $NextEndTime)
    }
}