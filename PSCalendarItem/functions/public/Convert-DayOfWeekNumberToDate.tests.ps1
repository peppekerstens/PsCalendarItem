#needs pester 5 or better!

BeforeAll {
    # DON'T use $MyInvocation.MyCommand.Path
    #for some vague reason . $PSCommandPath.Replace('.Tests.ps1','.ps1') does not work on this file
    . ($PSCommandPath -Replace ('\.Tests\.ps1', '.ps1'))

    #just a scaffolding for Mockable function. Otherwise 'CommandNotFoundException: ....' 
    function Get-DayOfWeek {
        return "Monday"
    }
}

Describe 'Integration tests Convert-DayOfWeekNumberToDate' {

    Context 'base functionality' {
        BeforeAll {
            Mock -CommandName Get-Date -MockWith { return [datetime]"Monday, July 27, 2020 12:00:00 AM" }
            Mock -CommandName Get-Date -MockWith { return [datetime]"Wednesday, July 1, 2020 12:00:00 AM" } -ParameterFilter { $Day -and ($Day -eq 1) }
            Mock -CommandName Get-DayOfWeek -MockWith { return "Monday" }
        }

        It 'Monday on first week (1)' {
            (Convert-DayOfWeekNumberToDate -DayOfWeek 'Mo' -Week 1) -eq [datetime]'Monday, July 6, 2020' | Should -Be $true
        }
        It 'Monday on week 2' {
            (Convert-DayOfWeekNumberToDate -DayOfWeek 'Mo' -Week 2) -eq [datetime]'Monday, July 13, 2020' | Should -Be $true
        }
        It 'Monday on week 3' {
            (Convert-DayOfWeekNumberToDate -DayOfWeek 'Mo' -Week 3) -eq [datetime]'Monday, July 20, 2020' | Should -Be $true
        }
        It 'Monday on week 4' {
            (Convert-DayOfWeekNumberToDate -DayOfWeek 'Mo' -Week 4) -eq [datetime]'Monday, July 27, 2020' | Should -Be $true
        }
        It 'Monday on last week (-1)' {
            (Convert-DayOfWeekNumberToDate -DayOfWeek 'Mo' -Week -1) -eq [datetime]'Monday, July 27, 2020' | Should -Be $true
        }      
    }

    Context 'reference' {
        #Mock Get-Date { return [datetime]"Monday, July 27, 2020 12:00:00 AM" }
        #Mock Get-Date { return [datetime]"Wednesday, July 1, 2020 12:00:00 AM" } -ParameterFilter { $Day -and ($Day -eq 1) }
        It 'number entry' {
            Mock Get-DayOfWeek { return "Monday" }
            (Convert-DayOfWeekNumberToDate -DayOfWeek 'Mo' -Week 1 -Reference "Monday, July 27, 2020 12:00:00 AM") -eq [datetime]'Monday, July 6, 2020' | Should -Be $true
        }
    }
}
