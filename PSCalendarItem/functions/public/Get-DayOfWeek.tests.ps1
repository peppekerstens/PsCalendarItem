#needs pester 5 or better!

BeforeAll {
    # DON'T use $MyInvocation.MyCommand.Path
    #for some vague reason . $PSCommandPath.Replace('.Tests.ps1','.ps1') does not work on this file
    . ($PSCommandPath -Replace ('\.Tests\.ps1', '.ps1'))
}

Describe "Integration tests $((Split-Path -Path $PSCommandPath -Leaf) -Replace '\.Tests\.ps1')" {

    Context 'single entry' {
        It 'get Monday' {
            Get-DayOfWeek -String 'm' | Should -Be 'Monday'
        }
        It 'get Monday' {
            Get-DayOfWeek -String 'mond' | Should -Be 'Monday'
        }
        It 'get Tuesday' {
            Get-DayOfWeek -String 'tu' | Should -Be 'Tuesday'
        }
        It 'get Wednesday' {
            Get-DayOfWeek -String 'w' | Should -Be 'Wednesday'
        }
        It 'get Thursday' {
            Get-DayOfWeek -String 'th' | Should -Be 'Thursday'
        }
        It 'get Friday' {
            Get-DayOfWeek -String 'f' | Should -Be 'Friday'
        }
        It 'get Saturday' {
            Get-DayOfWeek -String 'satur' | Should -Be 'Saturday'
        }
        It 'get Sunday' {
            Get-DayOfWeek -String 'su' | Should -Be 'Sunday'
        }     
    }

    Context 'multiple entry' {
        It 'get Monday and Tuesday' {
            Get-DayOfWeek -String 'm','tu' | Should -Be @('Monday','Tuesday')
        }
    }

    Context 'pipeline' {
        It 'single entry' {
            'm' | Get-DayOfWeek | Should -Be 'Monday'
        }
        It 'multiple entry' {
            'm','tu','we' | Get-DayOfWeek | Should -Be @('Monday','Tuesday','Wednesday')
        }
    }

    Context 'multiple results' {
        It 'enter t' {
            Get-DayOfWeek 't' | Should -Be @('Tuesday','Thursday')
        }
    }
}
