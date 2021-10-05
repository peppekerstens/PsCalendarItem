function Get-DayOfWeek
{ 
    <#  
    .SYNOPSIS   
        Converts provided substring into a valid DayOfWeek fullname
    
    .PARAMETER DayOfWeek 
        Provide a substring of the day of the week. Must be part of the English full name format. 

    .EXAMPLE  
        Get-DayOfWeek -String 'm'
    
    .EXAMPLE  
        Get-DayOfWeek 'tu'

    .EXAMPLE  
        @('m','tue','wedne','thursd','f','sa','su') | Get-DayOfWeek 
    #> 
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,ValueFromPipeline)]
        [string[]]$String
    )

    begin{
        $Days = @('Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday')
    }
    process{
        Foreach ($S in $String){
            $Days.Where{$_ -like "$($S)*"}
            #
            #elegant, but above method is fastest..
            #(0..6 | Foreach-Object {(Get-Date).adddays($_) } | Where-Object {$_.dayofweek -like "$($String)*"}).DayOfWeek
        }
    }
}