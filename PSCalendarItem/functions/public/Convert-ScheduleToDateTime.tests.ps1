#needs pester 5 or better!

BeforeAll {
    # DON'T use $MyInvocation.MyCommand.Path
    #for some vague reason . $PSCommandPath.Replace('.Tests.ps1','.ps1') does not work on this file
    . ($PSCommandPath -Replace ('\.Tests\.ps1', '.ps1'))

    #assumes that dependend functions are in same directory as this script
    . (Join-Path -Path (Split-Path -Path $PSCommandPath) -ChildPath 'Get-DayOfweek.ps1')
    #. (Join-Path -Path (Split-Path -Path $PSCommandPath) -ChildPath 'Convert-DayOfWeekNumberToDate.ps1')

    #just a scaffolding for Mockable function. Otherwise 'CommandNotFoundException: ....' 
    #function Get-DayOfWeek {
    #    return "Monday"
    #}
}


Describe 'Integration tests Convert-ScheduleToDateTime simplest' {

    Context 'one start item' {
        BeforeAll {
            Mock -CommandName Get-Date -MockWith { return [datetime]"Monday, July 27, 2020 12:00:00 AM" }
            #Mock -CommandName Get-Date -MockWith { return [datetime]"Wednesday, July 1, 2020 12:00:00 AM" } -ParameterFilter { $Day -and ($Day -eq 1) }
            #Mock -CommandName Get-DayOfWeek -MockWith { return "Monday" }
            $ScheduleJson = 
@'
{
    "start": ["20:00"]
}
'@

            $Schedule = ConvertFrom-Json $ScheduleJson
            $result = Convert-ScheduleToDateTime -Schedule $Schedule
        }

        It 'should have 0 EndDateTimes' {
            $result.EndDateTimes.Count | Should -Be 0
        }

        It 'should have 3 StartDateTimes' {
            $result.StartDateTimes.Count | Should -Be 3
        }

        It 'StartDateTimes result validation' {
            $result.StartDateTimes -contains [datetime]'Sunday, July 26, 2020 20:00:00' | Should -Be $true
            $result.StartDateTimes -contains [datetime]'Monday, July 27, 2020 20:00:00' | Should -Be $true
            $result.StartDateTimes -contains [datetime]'Tuesday, July 28, 2020 20:00:00' | Should -Be $true
        }   
    }

    Context 'one end item' {
        BeforeAll {
            Mock -CommandName Get-Date -MockWith { return [datetime]"Monday, July 27, 2020 12:00:00 AM" }
            #Mock -CommandName Get-Date -MockWith { return [datetime]"Wednesday, July 1, 2020 12:00:00 AM" } -ParameterFilter { $Day -and ($Day -eq 1) }
            #Mock -CommandName Get-DayOfWeek -MockWith { return "Monday" }
            $ScheduleJson = 
@'
{
    "end": ["20:00"]
}
'@

            $Schedule = ConvertFrom-Json $ScheduleJson
            $result = Convert-ScheduleToDateTime -Schedule $Schedule
        }

        It 'should have 0 StartDateTimes' {
            $result.StartDateTimes.Count | Should -Be 0
        }

        It 'should have 3 EndDateTimes' {
            $result.EndDateTimes.Count | Should -Be 3
        }

        It 'EndDateTimes result validation' {
            $result.EndDateTimes -contains [datetime]'Sunday, July 26, 2020 20:00:00' | Should -Be $true
            $result.EndDateTimes -contains [datetime]'Monday, July 27, 2020 20:00:00' | Should -Be $true
            $result.EndDateTimes -contains [datetime]'Tuesday, July 28, 2020 20:00:00' | Should -Be $true
        }   
    }

    Context 'start and end item' {
        BeforeAll {
            Mock -CommandName Get-Date -MockWith { return [datetime]"Monday, July 27, 2020 12:00:00 AM" }
            #Mock -CommandName Get-Date -MockWith { return [datetime]"Wednesday, July 1, 2020 12:00:00 AM" } -ParameterFilter { $Day -and ($Day -eq 1) }
            #Mock -CommandName Get-DayOfWeek -MockWith { return "Monday" }
            $ScheduleJson = 
@'
{
    "start": ["10:00"],
    "end": ["20:00"]
}
'@

            $Schedule = ConvertFrom-Json $ScheduleJson
            $result = Convert-ScheduleToDateTime -Schedule $Schedule
        }

        It 'should have 3 StartDateTimes' {
            $result.StartDateTimes.Count | Should -Be 3
        }

        It 'StartDateTimes result validation' {
            $result.StartDateTimes -contains [datetime]'Sunday, July 26, 2020 10:00:00' | Should -Be $true
            $result.StartDateTimes -contains [datetime]'Monday, July 27, 2020 10:00:00' | Should -Be $true
            $result.StartDateTimes -contains [datetime]'Tuesday, July 28, 2020 10:00:00' | Should -Be $true
        }

        It 'should have 3 EndDateTimes' {
            $result.EndDateTimes.Count | Should -Be 3
        }

        It 'EndDateTimes result validation' {
            $result.EndDateTimes -contains [datetime]'Sunday, July 26, 2020 20:00:00' | Should -Be $true
            $result.EndDateTimes -contains [datetime]'Monday, July 27, 2020 20:00:00' | Should -Be $true
            $result.EndDateTimes -contains [datetime]'Tuesday, July 28, 2020 20:00:00' | Should -Be $true
        }  
    }

    Context 'multiple start and end items' {
        BeforeAll {
            Mock -CommandName Get-Date -MockWith { return [datetime]"Monday, July 27, 2020 12:00:00 AM" }
            #Mock -CommandName Get-Date -MockWith { return [datetime]"Wednesday, July 1, 2020 12:00:00 AM" } -ParameterFilter { $Day -and ($Day -eq 1) }
            #Mock -CommandName Get-DayOfWeek -MockWith { return "Monday" }
            $ScheduleJson = 
@'
[
    {
        "start": ["10:00","21:00"],
        "end": ["20:00","22:00"]
    },
    {
        "start": "04:00",
        "end": "06:00"
    }
]
'@

            $Schedule = ConvertFrom-Json $ScheduleJson
            $result = Convert-ScheduleToDateTime -Schedule $Schedule
        }

        It 'should have 9 StartDateTimes' {
            $result.StartDateTimes.Count | Should -Be 9
        }

        It 'StartDateTimes result validation' {
            $result.StartDateTimes -contains [datetime]'Sunday, July 26, 2020 04:00:00' | Should -Be $true
            $result.StartDateTimes -contains [datetime]'Monday, July 27, 2020 04:00:00' | Should -Be $true
            $result.StartDateTimes -contains [datetime]'Tuesday, July 28, 2020 04:00:00' | Should -Be $true
            $result.StartDateTimes -contains [datetime]'Sunday, July 26, 2020 10:00:00' | Should -Be $true
            $result.StartDateTimes -contains [datetime]'Monday, July 27, 2020 10:00:00' | Should -Be $true
            $result.StartDateTimes -contains [datetime]'Tuesday, July 28, 2020 10:00:00' | Should -Be $true
            $result.StartDateTimes -contains [datetime]'Sunday, July 26, 2020 21:00:00' | Should -Be $true
            $result.StartDateTimes -contains [datetime]'Monday, July 27, 2020 21:00:00' | Should -Be $true
            $result.StartDateTimes -contains [datetime]'Tuesday, July 28, 2020 21:00:00' | Should -Be $true
        }

        It 'should have 9 EndDateTimes' {
            $result.EndDateTimes.Count | Should -Be 9
        }

        It 'EndDateTimes result validation' {
            $result.EndDateTimes -contains [datetime]'Sunday, July 26, 2020 06:00:00' | Should -Be $true
            $result.EndDateTimes -contains [datetime]'Monday, July 27, 2020 06:00:00' | Should -Be $true
            $result.EndDateTimes -contains [datetime]'Tuesday, July 28, 2020 06:00:00' | Should -Be $true
            $result.EndDateTimes -contains [datetime]'Sunday, July 26, 2020 20:00:00' | Should -Be $true
            $result.EndDateTimes -contains [datetime]'Monday, July 27, 2020 20:00:00' | Should -Be $true
            $result.EndDateTimes -contains [datetime]'Tuesday, July 28, 2020 20:00:00' | Should -Be $true
            $result.EndDateTimes -contains [datetime]'Sunday, July 26, 2020 22:00:00' | Should -Be $true
            $result.EndDateTimes -contains [datetime]'Monday, July 27, 2020 22:00:00' | Should -Be $true
            $result.EndDateTimes -contains [datetime]'Tuesday, July 28, 2020 22:00:00' | Should -Be $true
        }  
    }

    Context 'contradicting start and end items' {
        BeforeAll {
            Mock -CommandName Get-Date -MockWith { return [datetime]"Monday, July 27, 2020 12:00:00 AM" }
            #Mock -CommandName Get-Date -MockWith { return [datetime]"Wednesday, July 1, 2020 12:00:00 AM" } -ParameterFilter { $Day -and ($Day -eq 1) }
            #Mock -CommandName Get-DayOfWeek -MockWith { return "Monday" }
            $ScheduleJson = 
@'
[
    {
        "start": ["10:00"],
        "end": ["10:00"]
    },
    {
        "start": "04:00",
        "end": "04:00"
    }
]
'@

            $Schedule = ConvertFrom-Json $ScheduleJson
        }

        It 'should throw error' {
            $ErrResult = $false
            Try {
                Convert-ScheduleToDateTime -Schedule $Schedule
            }Catch [Microsoft.PowerShell.Commands.WriteErrorException] {
                $ErrResult = $true
            }
            $ErrResult | Should -Be $true
        }
    }

    Context 'invalid start items' {
        BeforeAll {
            Mock -CommandName Get-Date -MockWith { return [datetime]"Monday, July 27, 2020 12:00:00 AM" }
            #Mock -CommandName Get-Date -MockWith { return [datetime]"Wednesday, July 1, 2020 12:00:00 AM" } -ParameterFilter { $Day -and ($Day -eq 1) }
            #Mock -CommandName Get-DayOfWeek -MockWith { return "Monday" }
            $ScheduleJson = 
@'
[
    {
        "start": ["*","10:00"]
    }
]
'@

            $Schedule = ConvertFrom-Json $ScheduleJson
        }

        It 'should throw error' {
            $ErrResult = $false
            Try {
                Convert-ScheduleToDateTime -Schedule $Schedule
            }Catch [Microsoft.PowerShell.Commands.WriteErrorException] {
                $ErrResult = $true
            }
            $ErrResult | Should -Be $true
        }
    }

    Context 'invalid end items' {
        BeforeAll {
            Mock -CommandName Get-Date -MockWith { return [datetime]"Monday, July 27, 2020 12:00:00 AM" }
            #Mock -CommandName Get-Date -MockWith { return [datetime]"Wednesday, July 1, 2020 12:00:00 AM" } -ParameterFilter { $Day -and ($Day -eq 1) }
            #Mock -CommandName Get-DayOfWeek -MockWith { return "Monday" }
            $ScheduleJson = 
@'
[
    {
        "end": ["*","10:00"]
    }
]
'@

            $Schedule = ConvertFrom-Json $ScheduleJson
        }

        It 'should throw error' {
            $ErrResult = $false
            Try {
                Convert-ScheduleToDateTime -Schedule $Schedule
            }Catch [Microsoft.PowerShell.Commands.WriteErrorException] {
                $ErrResult = $true
            }
            $ErrResult | Should -Be $true
        }
    }

    Context 'invalid start and end items' {
        BeforeAll {
            Mock -CommandName Get-Date -MockWith { return [datetime]"Monday, July 27, 2020 12:00:00 AM" }
            #Mock -CommandName Get-Date -MockWith { return [datetime]"Wednesday, July 1, 2020 12:00:00 AM" } -ParameterFilter { $Day -and ($Day -eq 1) }
            #Mock -CommandName Get-DayOfWeek -MockWith { return "Monday" }
            $ScheduleJson = 
@'
[
    {
        "start": "*",
        "end": "*"
    }
]
'@

            $Schedule = ConvertFrom-Json $ScheduleJson
        }

        It 'should throw error' {
            $ErrResult = $false
            Try {
                Convert-ScheduleToDateTime -Schedule $Schedule
            }Catch [Microsoft.PowerShell.Commands.WriteErrorException] {
                $ErrResult = $true
            }
            $ErrResult | Should -Be $true
        }
    }

    Context 'invalid seperate start and end items' {
        BeforeAll {
            Mock -CommandName Get-Date -MockWith { return [datetime]"Monday, July 27, 2020 12:00:00 AM" }
            #Mock -CommandName Get-Date -MockWith { return [datetime]"Wednesday, July 1, 2020 12:00:00 AM" } -ParameterFilter { $Day -and ($Day -eq 1) }
            #Mock -CommandName Get-DayOfWeek -MockWith { return "Monday" }
            $ScheduleJson = 
@'
[
    {
        "start": "*"
    },
    {
        "end": "*"
    }
]
'@

            $Schedule = ConvertFrom-Json $ScheduleJson
        }

        It 'should throw error' {
            $ErrResult = $false
            Try {
                Convert-ScheduleToDateTime -Schedule $Schedule
            }Catch [Microsoft.PowerShell.Commands.WriteErrorException] {
                $ErrResult = $true
            }
            $ErrResult | Should -Be $true
        }
    }
}



Describe 'Integration tests Convert-ScheduleToDateTime day' {

    Context 'single' {
        BeforeAll {
            Mock -CommandName Get-Date -MockWith { return [datetime]"Monday, July 27, 2020 12:00:00 AM" }
            #Mock -CommandName Get-Date -MockWith { return [datetime]"Wednesday, July 1, 2020 12:00:00 AM" } -ParameterFilter { $Day -and ($Day -eq 1) }
            #Mock -CommandName Get-DayOfWeek -MockWith { return "Monday" }
            $ScheduleJson = 
@'
{
    "day": ["mo"],
    "start": ["07:00"],
    "end": ["10:00"]
}
'@

            $Schedule = ConvertFrom-Json $ScheduleJson
            $result = Convert-ScheduleToDateTime -Schedule $Schedule
        }

        It 'should have 1 EndDateTimes' {
            $result.EndDateTimes.Count | Should -Be 1
        }

        It 'should have 1 StartDateTimes' {
            $result.StartDateTimes.Count | Should -Be 1
        }

        It 'result validation' {
            $result.StartDateTimes -contains [datetime]'Monday, July 27, 2020 07:00:00' | Should -Be $true
            $result.EndDateTimes -contains [datetime]'Monday, July 27, 2020 10:00:00' | Should -Be $true
        }   
    }

    Context 'multiple' {
        BeforeAll {
            Mock -CommandName Get-Date -MockWith { return [datetime]"Monday, July 27, 2020 12:00:00 AM" }
            #Mock -CommandName Get-Date -MockWith { return [datetime]"Wednesday, July 1, 2020 12:00:00 AM" } -ParameterFilter { $Day -and ($Day -eq 1) }
            #Mock -CommandName Get-DayOfWeek -MockWith { return "Monday" }
            $ScheduleJson = 
@'
[
    {
        "day": ["su"],
        "start": ["07:00"]
    },
    {
        "day": ["mo"],
        "end": ["10:00"]
    },
    {
        "day": ["mo","tu"],
        "start": ["17:00"],
        "end": ["21:00"]
    }
]
'@

            $Schedule = ConvertFrom-Json $ScheduleJson
            $result = Convert-ScheduleToDateTime -Schedule $Schedule
        }

        It 'should have 3 EndDateTimes' {
            $result.EndDateTimes.Count | Should -Be 3
        }

        It 'should have 3 StartDateTimes' {
            $result.StartDateTimes.Count | Should -Be 3
        }

        It 'result validation' {
            $result.StartDateTimes -contains [datetime]'Sunday, July 26, 2020 07:00:00' | Should -Be $true
            $result.EndDateTimes -contains [datetime]'Monday, July 27, 2020 10:00:00' | Should -Be $true
            $result.StartDateTimes -contains [datetime]'Monday, July 27, 2020 17:00:00' | Should -Be $true
            $result.EndDateTimes -contains [datetime]'Monday, July 27, 2020 21:00:00' | Should -Be $true
            $result.StartDateTimes -contains [datetime]'Tuesday, July 28, 2020 17:00:00' | Should -Be $true
            $result.EndDateTimes -contains [datetime]'Tuesday, July 28, 2020 21:00:00' | Should -Be $true
        }   
    }

    Context 'wildcard day' {
        BeforeAll {
            Mock -CommandName Get-Date -MockWith { return [datetime]"Monday, July 27, 2020 12:00:00 AM" }
            #Mock -CommandName Get-Date -MockWith { return [datetime]"Wednesday, July 1, 2020 12:00:00 AM" } -ParameterFilter { $Day -and ($Day -eq 1) }
            #Mock -CommandName Get-DayOfWeek -MockWith { return "Monday" }
            $ScheduleJson = 
@'
[
    {
        "day": "*",
        "start": "07:00",
        "end": "10:00"
    }
]
'@

            $Schedule = ConvertFrom-Json $ScheduleJson
            $result = Convert-ScheduleToDateTime -Schedule $Schedule
        }

        It 'should have 3 EndDateTimes' {
            $result.EndDateTimes.Count | Should -Be 3
        }

        It 'should have 3 StartDateTimes' {
            $result.StartDateTimes.Count | Should -Be 3
        }

        It 'result validation' {
            $result.StartDateTimes -contains [datetime]'Sunday, July 26, 2020 07:00:00' | Should -Be $true
            $result.EndDateTimes -contains [datetime]'Sunday, July 26,, 2020 10:00:00' | Should -Be $true
            $result.StartDateTimes -contains [datetime]'Monday, July 27, 2020 07:00:00' | Should -Be $true
            $result.EndDateTimes -contains [datetime]'Monday, July 27, 2020 10:00:00' | Should -Be $true
            $result.StartDateTimes -contains [datetime]'Tuesday, July 28, 2020 07:00:00' | Should -Be $true
            $result.EndDateTimes -contains [datetime]'Tuesday, July 28, 2020 10:00:00' | Should -Be $true
        }   
    }

    Context 'wildcard start time' {
        BeforeAll {
            Mock -CommandName Get-Date -MockWith { return [datetime]"Monday, July 27, 2020 12:00:00 AM" }
            #Mock -CommandName Get-Date -MockWith { return [datetime]"Wednesday, July 1, 2020 12:00:00 AM" } -ParameterFilter { $Day -and ($Day -eq 1) }
            #Mock -CommandName Get-DayOfWeek -MockWith { return "Monday" }
            $ScheduleJson = 
@'
[
    {
        "day": ["mo","tu"],
        "start": "*"
    }
]
'@

            $Schedule = ConvertFrom-Json $ScheduleJson
            $result = Convert-ScheduleToDateTime -Schedule $Schedule
        }

        It 'should have 0 EndDateTimes' {
            $result.EndDateTimes.Count | Should -Be 0
        }

        It 'should have 2 StartDateTimes' {
            $result.StartDateTimes.Count | Should -Be 2
        }

        It 'result validation' {
            $result.StartDateTimes -contains [datetime]'Tuesday, July 28, 2020 00:00:00' | Should -Be $true
            $result.StartDateTimes -contains [datetime]'Monday, July 27, 2020 00:00:00' | Should -Be $true
        }   
    }

    Context 'wildcard end time' {
        BeforeAll {
            Mock -CommandName Get-Date -MockWith { return [datetime]"Monday, July 27, 2020 12:00:00 AM" }
            #Mock -CommandName Get-Date -MockWith { return [datetime]"Wednesday, July 1, 2020 12:00:00 AM" } -ParameterFilter { $Day -and ($Day -eq 1) }
            #Mock -CommandName Get-DayOfWeek -MockWith { return "Monday" }
            $ScheduleJson = 
@'
[
    {
        "day": ["mo","tu"],
        "end": "*"
    }
]
'@

            $Schedule = ConvertFrom-Json $ScheduleJson
            $result = Convert-ScheduleToDateTime -Schedule $Schedule
        }

        It 'should have 2 EndDateTimes' {
            $result.EndDateTimes.Count | Should -Be 2
        }

        It 'should have 0 StartDateTimes' {
            $result.StartDateTimes.Count | Should -Be 0
        }

        It 'result validation' {
            $result.EndDateTimes -contains [datetime]'Tuesday, July 28, 2020 00:00:00' | Should -Be $true
            $result.EndDateTimes -contains [datetime]'Monday, July 27, 2020 00:00:00' | Should -Be $true
        }   
    }

    Context 'conflicting start- and wildcard end time' {
        BeforeAll {
            Mock -CommandName Get-Date -MockWith { return [datetime]"Monday, July 27, 2020 12:00:00 AM" }
            #Mock -CommandName Get-Date -MockWith { return [datetime]"Wednesday, July 1, 2020 12:00:00 AM" } -ParameterFilter { $Day -and ($Day -eq 1) }
            #Mock -CommandName Get-DayOfWeek -MockWith { return "Monday" }
            $ScheduleJson = 
@'
[
    {
        "day": ["mo","tu"],
        "end": "*"
    },
    {
        "start": "08:00"
    }, 
]
'@

            $Schedule = ConvertFrom-Json $ScheduleJson
        }

        It 'should throw error' {
            $ErrResult = $false
            Try {
                Convert-ScheduleToDateTime -Schedule $Schedule
            }Catch [Microsoft.PowerShell.Commands.WriteErrorException] {
                $ErrResult = $true
            }
            $ErrResult | Should -Be $true
        }   
    }

    Context 'conflicting end- and wildcard start time' {
        BeforeAll {
            Mock -CommandName Get-Date -MockWith { return [datetime]"Monday, July 27, 2020 12:00:00 AM" }
            #Mock -CommandName Get-Date -MockWith { return [datetime]"Wednesday, July 1, 2020 12:00:00 AM" } -ParameterFilter { $Day -and ($Day -eq 1) }
            #Mock -CommandName Get-DayOfWeek -MockWith { return "Monday" }
            $ScheduleJson = 
@'
[
    {
        "day": ["mo","tu"],
        "start": "*"
    },
    {
        "end": "08:00"
    }, 
]
'@

            $Schedule = ConvertFrom-Json $ScheduleJson
        }

        It 'should throw error' {
            $ErrResult = $false
            Try {
                Convert-ScheduleToDateTime -Schedule $Schedule
            }Catch [Microsoft.PowerShell.Commands.WriteErrorException] {
                $ErrResult = $true
            }
            $ErrResult | Should -Be $true
        }   
    }
}



Describe 'Integration tests Convert-ScheduleToDateTime week' {

    Context 'single item' {
        BeforeAll {
            Mock -CommandName Get-Date -MockWith { return [datetime]"Monday, July 27, 2020 12:00:00 AM" }
            #Mock -CommandName Get-Date -MockWith { return [datetime]"Wednesday, July 1, 2020 12:00:00 AM" } -ParameterFilter { $Day -and ($Day -eq 1) }
            #Mock -CommandName Get-DayOfWeek -MockWith { return "Monday" }
            $ScheduleJson = 
@'
{
    "week": 3,
    "day": ["mo"],
    "start": ["07:00"],
    "end": ["10:00"]
}
'@

            $Schedule = ConvertFrom-Json $ScheduleJson
            $result = Convert-ScheduleToDateTime -Schedule $Schedule
        }

        It 'should have 2 EndDateTimes' {
            $result.EndDateTimes.Count | Should -Be 2
        }

        It 'should have 2 StartDateTimes' {
            $result.StartDateTimes.Count | Should -Be 2
        }

        It 'result validation' {
            $result.StartDateTimes -contains [datetime]'Monday, July 20, 2020 07:00:00' | Should -Be $true
            $result.EndDateTimes -contains [datetime]'Monday, July 20, 2020 10:00:00' | Should -Be $true
            $result.StartDateTimes -contains [datetime]'Monday, August 17, 2020 07:00:00' | Should -Be $true
            $result.EndDateTimes -contains [datetime]'Monday, August 17, 2020 10:00:00' | Should -Be $true
        }   
    }

    Context 'last week of month' {
        BeforeAll {
            Mock -CommandName Get-Date -MockWith { return [datetime]"Monday, July 27, 2020 12:00:00 AM" }
            #Mock -CommandName Get-Date -MockWith { return [datetime]"Wednesday, July 1, 2020 12:00:00 AM" } -ParameterFilter { $Day -and ($Day -eq 1) }
            #Mock -CommandName Get-DayOfWeek -MockWith { return "Monday" }
            $ScheduleJson = 
@'
{
    "week": -1,
    "day": ["mo"],
    "start": ["07:00"],
    "end": ["10:00"]
}
'@

            $Schedule = ConvertFrom-Json $ScheduleJson
            $result = Convert-ScheduleToDateTime -Schedule $Schedule
        }

        It 'should have 1 EndDateTimes' {
            $result.EndDateTimes.Count | Should -Be 1
        }

        It 'should have 1 StartDateTimes' {
            $result.StartDateTimes.Count | Should -Be 1
        }

        It 'result validation' {
            $result.StartDateTimes -contains [datetime]'Monday, June 29, 2020 07:00:00' | Should -Be $true
            $result.EndDateTimes -contains [datetime]'Monday, June 29, 2020 10:00:00' | Should -Be $true
        }   
    }

    Context 'multple items' {
        BeforeAll {
            Mock -CommandName Get-Date -MockWith { return [datetime]"Monday, July 27, 2020 12:00:00 AM" }
            #Mock -CommandName Get-Date -MockWith { return [datetime]"Wednesday, July 1, 2020 12:00:00 AM" } -ParameterFilter { $Day -and ($Day -eq 1) }
            #Mock -CommandName Get-DayOfWeek -MockWith { return "Monday" }
            $ScheduleJson = 
@'
{
    "week": [3,4],
    "day": ["mo"],
    "start": ["07:00"],
    "end": ["10:00"]
}
'@

            $Schedule = ConvertFrom-Json $ScheduleJson
            $result = Convert-ScheduleToDateTime -Schedule $Schedule
        }

        It 'should have 4 EndDateTimes' {
            $result.EndDateTimes.Count | Should -Be 4
        }

        It 'should have 4 StartDateTimes' {
            $result.StartDateTimes.Count | Should -Be 4
        }

        It 'result validation' {
            $result.StartDateTimes -contains [datetime]'Monday, July 20, 2020 07:00:00' | Should -Be $true
            $result.EndDateTimes -contains [datetime]'Monday, July 20, 2020 10:00:00' | Should -Be $true
            $result.StartDateTimes -contains [datetime]'Monday, August 17, 2020 07:00:00' | Should -Be $true
            $result.EndDateTimes -contains [datetime]'Monday, August 17, 2020 10:00:00' | Should -Be $true
        }   
    }

    Context 'one start, one stop' {
        BeforeAll {
            Mock -CommandName Get-Date -MockWith { return [datetime]"Monday, July 27, 2020 12:00:00 AM" }
            #Mock -CommandName Get-Date -MockWith { return [datetime]"Wednesday, July 1, 2020 12:00:00 AM" } -ParameterFilter { $Day -and ($Day -eq 1) }
            #Mock -CommandName Get-DayOfWeek -MockWith { return "Monday" }
            $ScheduleJson = 
@'
[
    {
        "week": 2,
        "day": ["mo"],
        "start": ["07:00"]
    },
    {
        "week": 4,
        "day": ["mo"],
        "end": ["10:00"],
    },
]
'@

            $Schedule = ConvertFrom-Json $ScheduleJson
            $result = Convert-ScheduleToDateTime -Schedule $Schedule
        }

        It 'should have 2 EndDateTimes' {
            $result.EndDateTimes.Count | Should -Be 2
        }

        It 'should have 2 StartDateTimes' {
            $result.StartDateTimes.Count | Should -Be 2
        }

        It 'result validation' {
            $result.StartDateTimes -contains [datetime]'Monday, July 13, 2020 07:00:00' | Should -Be $true
            $result.EndDateTimes -contains [datetime]'Monday, July 27, 2020 10:00:00' | Should -Be $true
            $result.StartDateTimes -contains [datetime]'Monday, August 10, 2020 07:00:00' | Should -Be $true
            $result.EndDateTimes -contains [datetime]'Monday, August 24, 2020 10:00:00' | Should -Be $true
        }   
    }
}



Describe 'Integration tests Convert-ScheduleToDateTime daynumber' {

    Context 'single' {
        BeforeAll {
            Mock -CommandName Get-Date -MockWith { return [datetime]"Monday, July 27, 2020 12:00:00 AM" }
            #Mock -CommandName Get-Date -MockWith { return [datetime]"Wednesday, July 1, 2020 12:00:00 AM" } -ParameterFilter { $Day -and ($Day -eq 1) }
            #Mock -CommandName Get-DayOfWeek -MockWith { return "Monday" }
            $ScheduleJson = 
@'
{
    "day": "10",
    "start": ["07:00"],
    "end": ["10:00"]
}
'@

            $Schedule = ConvertFrom-Json $ScheduleJson
            $result = Convert-ScheduleToDateTime -Schedule $Schedule
        }

        It 'should have 2 EndDateTimes' {
            $result.EndDateTimes.Count | Should -Be 2
        }

        It 'should have 2 StartDateTimes' {
            $result.StartDateTimes.Count | Should -Be 2
        }

        It 'result validation' {
            $result.StartDateTimes -contains [datetime]'Friday, July 10, 2020 07:00:00' | Should -Be $true
            $result.EndDateTimes -contains [datetime]'Friday, July 10, 2020 10:00:00' | Should -Be $true
            $result.StartDateTimes -contains [datetime]'Monday, August 10, 2020 07:00:00' | Should -Be $true
            $result.EndDateTimes -contains [datetime]'Monday, August 10, 2020 10:00:00' | Should -Be $true
        }   
    }

    Context 'multiple' {
        BeforeAll {
            Mock -CommandName Get-Date -MockWith { return [datetime]"Monday, July 27, 2020 12:00:00 AM" }
            #Mock -CommandName Get-Date -MockWith { return [datetime]"Wednesday, July 1, 2020 12:00:00 AM" } -ParameterFilter { $Day -and ($Day -eq 1) }
            #Mock -CommandName Get-DayOfWeek -MockWith { return "Monday" }
            $ScheduleJson = 
@'
[
    {
        "day": "10",
        "start": ["07:00"],
        "end": ["10:00"]
    },
    {
        "day": 11,
        "start": ["07:00"],
        "end": ["10:00"]
    },
    {
        "day": [12,13],
        "start": ["07:00"],
        "end": ["10:00"]
    },  
]
'@

            $Schedule = ConvertFrom-Json $ScheduleJson
            $result = Convert-ScheduleToDateTime -Schedule $Schedule
        }

        It 'should have 8 EndDateTimes' {
            $result.EndDateTimes.Count | Should -Be 8
        }

        It 'should have 8 StartDateTimes' {
            $result.StartDateTimes.Count | Should -Be 8
        }

        It 'result validation' {
            $result.StartDateTimes -contains [datetime]'Friday, July 10, 2020 07:00:00' | Should -Be $true
            $result.EndDateTimes -contains [datetime]'Friday, July 10, 2020 10:00:00' | Should -Be $true
            $result.StartDateTimes -contains [datetime]'Monday, August 10, 2020 07:00:00' | Should -Be $true
            $result.EndDateTimes -contains [datetime]'Monday, August 10, 2020 10:00:00' | Should -Be $true
            $result.StartDateTimes -contains [datetime]'Saturday, July 11, 2020 07:00:00' | Should -Be $true
            $result.EndDateTimes -contains [datetime]'Saturday, July 11, 2020 10:00:00' | Should -Be $true
            $result.StartDateTimes -contains [datetime]'Tuesday, August 11, 2020 07:00:00' | Should -Be $true
            $result.EndDateTimes -contains [datetime]'Tuesday, August 11, 2020 10:00:00' | Should -Be $true
            $result.StartDateTimes -contains [datetime]'Sunday, July 12, 2020 07:00:00' | Should -Be $true
            $result.EndDateTimes -contains [datetime]'Sunday, July 12, 2020 10:00:00' | Should -Be $true
            $result.StartDateTimes -contains [datetime]'Wednesday, August 12, 2020 07:00:00' | Should -Be $true
            $result.EndDateTimes -contains [datetime]'Wednesday, August 12, 2020 10:00:00' | Should -Be $true
            $result.StartDateTimes -contains [datetime]'Monday, July 13, 2020 07:00:00' | Should -Be $true
            $result.EndDateTimes -contains [datetime]'Monday, July 13, 2020 10:00:00' | Should -Be $true
            $result.StartDateTimes -contains [datetime]'Thursday, August 13, 2020 07:00:00' | Should -Be $true
            $result.EndDateTimes -contains [datetime]'Thursday, August 13, 2020 10:00:00' | Should -Be $true
        }   
    }

    Context 'last' {
        BeforeAll {
            Mock -CommandName Get-Date -MockWith { return [datetime]"Monday, July 27, 2020 12:00:00 AM" }
            #Mock -CommandName Get-Date -MockWith { return [datetime]"Wednesday, July 1, 2020 12:00:00 AM" } -ParameterFilter { $Day -and ($Day -eq 1) }
            #Mock -CommandName Get-DayOfWeek -MockWith { return "Monday" }
            $ScheduleJson = 
@'
[
    {
        "day": -1,
        "start": "07:00",
        "end": "10:00"
    }
]
'@

            $Schedule = ConvertFrom-Json $ScheduleJson
            $result = Convert-ScheduleToDateTime -Schedule $Schedule
        }

        It 'should have 2 EndDateTimes' {
            $result.EndDateTimes.Count | Should -Be 2
        }

        It 'should have 2 StartDateTimes' {
            $result.StartDateTimes.Count | Should -Be 2
        }

        It 'result validation' {
            $result.StartDateTimes -contains [datetime]'Tuesday, June 30, 2020 07:00:00' | Should -Be $true
            $result.EndDateTimes -contains [datetime]'Tuesday, June 30, 2020 10:00:00' | Should -Be $true
            $result.StartDateTimes -contains [datetime]'Friday, July 31, 2020 07:00:00' | Should -Be $true
            $result.EndDateTimes -contains [datetime]'Friday, July 31, 2020 10:00:00' | Should -Be $true
        }   
    }
}