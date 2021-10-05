#needs pester 5 or better!

BeforeAll {
    # DON'T use $MyInvocation.MyCommand.Path
    #for some vague reason . $PSCommandPath.Replace('.Tests.ps1','.ps1') does not work on this file
    . ($PSCommandPath -Replace('\.Tests\.ps1','.ps1'))
}

Describe 'Integration tests Assert-ScheduledEvent' {
    Context 'no reference parameter' {
        BeforeAll{
            Mock Get-Date { return [datetime]"11:00" }
            Mock Write-Warning {}
        }
        It 'only Start before' {
            Assert-ScheduledEvent -Start '10:00' | Should -Be $true
            Assert-MockCalled Write-Warning
        }
        It 'only Start after' {
            Assert-ScheduledEvent -Start '13:00' | Should -Be $false
            Assert-MockCalled Write-Warning
        }
        It 'only end before' {
            Assert-ScheduledEvent -End '10:00' | Should -Be $false
            Assert-MockCalled Write-Warning
        }
        It 'only end after' {
            Assert-ScheduledEvent -End '17:00' | Should -Be $true
            Assert-MockCalled Write-Warning
        }
        It 'Start and end before' {
            Assert-ScheduledEvent -Start '13:00' -End '17:00' | Should -Be $false
        }
        It 'Start and end within' {
            Assert-ScheduledEvent -Start '10:00' -End '17:00' | Should -Be $true
        }
        It 'Start and end after' {
            Assert-ScheduledEvent -Start '05:00' -End '10:00' | Should -Be $false
        }
        It 'overlapping Start and end' {
            Assert-ScheduledEvent -Start '05:00' -End '05:00' | Should -Be $false
        }
        It 'empty collection Start and end' {
            Assert-ScheduledEvent -Start @() -End @() | Should -Be $false
        }
        It 'empty hash Start and end' {
            Assert-ScheduledEvent -Start @{} -End @{} | Should -Be $false
        }
    }

    Context 'with reference parameter' {
        BeforeAll{
            Mock Write-Warning {}
        }
        It 'only Start before' {
            Assert-ScheduledEvent -Start '10:00' -Reference '07:00' | Should -Be $false
            Assert-MockCalled Write-Warning
        }
        It 'only Start after' {
            Assert-ScheduledEvent -Start '10:00' -Reference '11:00' | Should -Be $true
            Assert-MockCalled Write-Warning
        }
        It 'only end before' {
            Assert-ScheduledEvent -End '17:00' -Reference '10:00' | Should -Be $true
            Assert-MockCalled Write-Warning
        }
        It 'only end before' {
            Assert-ScheduledEvent -End '17:00' -Reference '22:00' | Should -Be $false
            Assert-MockCalled Write-Warning
        }

        It 'inside timespan' {
            Assert-ScheduledEvent -Start '07:00' -End '17:00' -Reference '13:00' | Should -Be $true
        }
        It 'before timespan' {
            Assert-ScheduledEvent -Start '07:00' -End '17:00' -Reference '05:00' | Should -Be $false
        }
        It 'after timespan' {
            Assert-ScheduledEvent -Start '07:00' -End '17:00' -Reference '22:00' | Should -Be $false
        }
    }

    Context 'multiple time entries' {
        BeforeAll{
            Mock Write-Warning {}
        }
        It 'only Start before' {
            Assert-ScheduledEvent -Start @('07:00','10:00') -Reference '11:00' | Should -Be $true
            Assert-MockCalled Write-Warning
        }
        It 'only Start after' {
            Assert-ScheduledEvent -Start @('12:00','17:00') -Reference '11:00' | Should -Be $false
            Assert-MockCalled Write-Warning
        }
        It 'only end before' {
            Assert-ScheduledEvent -End @('07:00','10:00') -Reference '11:00' | Should -Be $false
            Assert-MockCalled Write-Warning
        }
        It 'only end after' {
            Assert-ScheduledEvent -End @('12:00','17:00') -Reference '11:00' | Should -Be $true
            Assert-MockCalled Write-Warning
        }

        It 'mixed Start' {
            Assert-ScheduledEvent -Start @('07:00','17:00') -Reference '11:00' | Should -Be $true
            Assert-MockCalled Write-Warning
        }
        It 'mixed end' {
            Assert-ScheduledEvent -End @('07:00','17:00') -Reference '11:00' | Should -Be $false
            Assert-MockCalled Write-Warning
        }

        It 'inside timespan 1' {
            Assert-ScheduledEvent -Start @('07:00','17:00') -End @('10:00','23:00') -Reference '09:00' | Should -Be $true
        }
        It 'inside timespan 2' {
            Assert-ScheduledEvent -Start @('07:00','17:00') -End @('10:00','23:00') -Reference '19:00' | Should -Be $true
        }
        It 'before timespan 1' {
            Assert-ScheduledEvent -Start @('07:00','17:00') -End @('10:00','23:00') -Reference '06:00' | Should -Be $false
        }
        It 'between timespan 1 and 2' {
            Assert-ScheduledEvent -Start @('07:00','17:00') -End @('10:00','23:00') -Reference '11:59' | Should -Be $false
        }
        It 'after timespan 2' {
            Assert-ScheduledEvent -Start @('07:00','17:00') -End @('10:00','23:00') -Reference '23:30' | Should -Be $false
        }
    }

    Context 'complex entries' {
        BeforeAll{
            Mock Write-Warning {}
        }
        It 'only Start' {
            Assert-ScheduledEvent -Start @('Wednesday, July 29, 2020 17:00','Thursday, July 30, 2020 07:00') -Reference 'Thursday, July 30, 2020 06:00' | Should -Be $true
            Assert-MockCalled Write-Warning
        }
        It 'only end before' {
            Assert-ScheduledEvent -End @('Wednesday, July 29, 2020 17:00','Thursday, July 30, 2020 07:00') -Reference 'Thursday, July 30, 2020 08:00' | Should -Be $false
            Assert-MockCalled Write-Warning
        }
        It 'only end after' {
            Assert-ScheduledEvent -End @('Wednesday, July 29, 2020 17:00','Thursday, July 30, 2020 09:00') -Reference 'Thursday, July 30, 2020 08:00' | Should -Be $false
            Assert-MockCalled Write-Warning
        }

        It 'only Start, scope outside of reference' {
            Assert-ScheduledEvent -Start @('Wednesday, July 29, 2020 17:00','Friday, July 31, 2020 07:00') -Reference 'Thursday, July 30, 2020 06:00' | Should -Be $true
            Assert-MockCalled Write-Warning
        }
        It 'only end, scope outside of reference' {
            Assert-ScheduledEvent -End @('Wednesday, July 29, 2020 17:00','Friday, July 31, 2020 07:00') -Reference 'Thursday, July 30, 2020 06:00' | Should -Be $false
            Assert-MockCalled Write-Warning
        }

        It 'before timespan 1' {
            Assert-ScheduledEvent -Start @([datetime]'Thursday, July 30, 2020 07:00','Friday, July 31, 2020 17:00') -End @('Thursday, July 30, 2020 10:00','Friday, July 31, 2020 23:00') -Reference 'Thursday, July 30, 2020 06:00' | Should -Be $false
        }
        It 'inside timespan 1' {
            Assert-ScheduledEvent -Start @([datetime]'Thursday, July 30, 2020 07:00','Friday, July 31, 2020 17:00') -End @('Thursday, July 30, 2020 10:00','Friday, July 31, 2020 23:00') -Reference 'Thursday, July 30, 2020 09:00' | Should -Be $true
        }
        It 'after timespan 1' {
            Assert-ScheduledEvent -Start @([datetime]'Thursday, July 30, 2020 07:00','Friday, July 31, 2020 17:00') -End @('Thursday, July 30, 2020 10:00','Friday, July 31, 2020 23:00') -Reference 'Thursday, July 30, 2020 13:00' | Should -Be $false
        }
        It 'inside timespan 2' {
            Assert-ScheduledEvent -Start @([datetime]'Thursday, July 30, 2020 07:00','Friday, July 31, 2020 17:00') -End @('Thursday, July 30, 2020 10:00','Friday, July 31, 2020 23:00') -Reference 'Friday, July 31, 2020 20:00' | Should -Be $true
        }
        It 'after timespan 2' {
            Assert-ScheduledEvent -Start @([datetime]'Thursday, July 30, 2020 07:00','Friday, July 31, 2020 17:00') -End @('Thursday, July 30, 2020 10:00','Friday, July 31, 2020 23:00') -Reference 'Friday, July 31, 2020 23:30' | Should -Be $false
        }
    }
}

