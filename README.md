# PsCalendarItem
## Synopsys

This module consists of a collection of functions which assert if one or more calendars item are at hand during the provided time period.  

## Description

## Limitations 

At this point, any and every defined calender item within the defined source is assumed to be of/for the same purpose. In other words; this module is not able to maintain events for different purposes within one run. This is still achievable by referencing different calendar sources for different purposes and running the functions within this module against those different sources sequential or parallel.


# Getting Started

## Dependencies

This module is tested on PowerShell 5.1 and PowerShell 7.0, running on a Windows platform. Although other versions and platforms may work, it is certain that version 5.1 is the required minimum.

## Installing

At this point, there is no package. Installing this module in the most 'proper manner' means copying it in any of following directories:

### PowerShell 5

```PowerShell
$env:WINDIR\System32\WindowsPowerShell\v1.0\Modules
$env:ProgramFiles\WindowsPowerShell\Modules
[Environment]::GetFolderPath("MyDocuments")\WindowsPowerShell\Modules
```

### PowerShell 7

```PowerShell
$env:ProgramFiles\PowerShell\[version]\Modules
[Environment]::GetFolderPath("MyDocuments")\PowerShell\Modules
```
# Generic examples

