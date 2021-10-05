#needs pester 5 or better!

BeforeAll {
    # DON'T use $MyInvocation.MyCommand.Path
    #for some vague reason . $PSCommandPath.Replace('.Tests.ps1','.ps1') does not work on this file
    . ($PSCommandPath -Replace ('\.Tests\.ps1', '.ps1'))

    #assumes that dependend functions are in same directory as this script
    . (Join-Path -Path (Split-Path -Path $PSCommandPath) -ChildPath 'Get-DayOfweek.ps1')
    . (Join-Path -Path (Split-Path -Path $PSCommandPath) -ChildPath 'Convert-ScheduleToDateTime.ps1')
    . (Join-Path -Path (Split-Path -Path $PSCommandPath) -ChildPath 'Assert-ScheduledEvent.ps1')

    Mock -CommandName Get-Date -MockWith { return [datetime]"Monday, July 27, 2020 11:00:00 AM" }
}

Describe "$((Split-Path -Path $PSCommandPath -Leaf) -Replace '\.Tests\.ps1') sut depend functions" {
    It 'Get-DayOfweek loaded'{
        (Get-Command Get-DayOfweek) -and $true | Should -Be $true
    }
    It 'Convert-ScheduleToDateTime loaded'{
        (Get-Command Convert-ScheduleToDateTime) -and $true | Should -Be $true
    }
    It 'Assert-ScheduledEvent loaded'{
        (Get-Command Assert-ScheduledEvent) -and $true | Should -Be $true
    }
}


Describe 'Integration tests Get-CalendarEvent' {
    Context 'one event with only start' {
        BeforeAll {
            $ScheduleJson = 
@'
{
    "start": ["20:00"]
}
'@

            $Schedule = ConvertFrom-Json $ScheduleJson
            $result = Get-CalendarEvent -Schedule $Schedule
        }

        It 'should have 1 result' {
            $result.Count | Should -Be 1
        }

        It 'result should be input' {
            $result -eq $schedule | Should -Be $true
        }  
    }

    Context 'one event with oly end' {
        BeforeAll {
            $ScheduleJson = 
@'
{
    "end": ["20:00"]
}
'@

            $Schedule = ConvertFrom-Json $ScheduleJson
            $result = Get-CalendarEvent -Schedule $Schedule
        }

        It 'should have 0 result' {
            $result.Count | Should -Be 0
        }  
    }

    Context 'one event' {
        BeforeAll {
            $ScheduleJson = 
@'
{
    "start": ["10:00"],
    "end": ["20:00"]
}
'@

            $Schedule = ConvertFrom-Json $ScheduleJson
            $result = Get-CalendarEvent -Schedule $Schedule
        }

        It 'should have 1 result' {
            $result.Count | Should -Be 1
        }

        It 'result should be input' {
            $result -eq $schedule | Should -Be $true
        }   
    }

    Context 'multiple events' {
        BeforeAll {
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
            $result = Get-CalendarEvent -Schedule $Schedule
        }

        It 'should have 1 result' {
            $result.Count | Should -Be 1
        }

        It 'result should first item of input' {
            $result -eq $schedule[0] | Should -Be $true
        }   
    }

    Context 'multiple events with payload' {
        BeforeAll {
            $ScheduleJson = 
@'
[
    {
        "start": "04:00",
        "end": "06:00",
        "dummy": "payload1"
    },
    {
        "start": ["10:00"],
        "end": ["12:00"],
        "dummy": "payload2"
    },
    {
        "start": "20:00",
        "end": "23:00",
        "dummy": "payload3"
    }
]
'@
            $Schedule = ConvertFrom-Json $ScheduleJson
            $result = Get-CalendarEvent -Schedule $Schedule
        }

        It 'should have 1 result' {
            $result.Count | Should -Be 1
        }

        It 'result should second item of input' {
            $result -eq $schedule[1] | Should -Be $true
        }

        It 'result contains extra payload' {
            $result.dummy | Should -Be "payload2"
        } 
    }

    Context 'multiple matching events' {
        BeforeAll {
            $ScheduleJson = 
@'
[
    {
        "start": "09:00",
        "end": "13:00",
        "dummy": "payload1"
    },
    {
        "start": ["10:00"],
        "end": ["12:00"],
        "dummy": "payload2"
    },
    {
        "start": "20:00",
        "end": "23:00",
        "dummy": "payload3"
    }
]
'@
            $Schedule = ConvertFrom-Json $ScheduleJson
            $result = Get-CalendarEvent -Schedule $Schedule
        }

        It 'should have 2 results' {
            $result.Count | Should -Be 2
        }

        It 'result should contain first and second item of input' {
            $result -eq $schedule[0] | Should -Be $true
            $result -eq $schedule[1] | Should -Be $true
        }

        It 'result contains extra payload' {
            $result[0].dummy | Should -Be "payload1"
            $result[1].dummy | Should -Be "payload2"
        } 
    }
}