###########################################################
# CalendarsDemo.ps1
#
# Wayne Lindimore
# wlindimore@gmail.com
# AdminsCache.Wordpress.com
#
# 7-20-13
# GUI Uses WinForms MonthCalendar & DateTimePicker Classes
# https://adminscache.wordpress.com/2013/08/13/two-calendar-guis-for-powershell/
###########################################################
Add-Type -AssemblyName System.Windows.Forms

# Main Form 
$mainForm = New-Object System.Windows.Forms.Form
$mainForm.Font = "Comic Sans MS,8.25"
$mainForm.Text = " Calendar Controls Demo"
$mainForm.ForeColor = "White"
$mainForm.BackColor = "DarkOliveGreen"
$mainForm.Width = 400
$mainForm.Height = 300

# MonthCalendar
$monthCal = New-Object System.Windows.Forms.MonthCalendar
$monthCal.Location = "8,24"
$monthCal.MinDate = New-Object System.DateTime(2013, 1, 1)
$monthCal.MinDate = "01/01/2012"       # Minimum Date Dispalyed
$monthCal.MaxDate = "12/31/2013"       # Maximum Date Dispalyed
$monthCal.MaxSelectionCount = 1        # Max number of days that can be selected
$monthCal.ShowToday = $false           # Show the Today Banner at bottom
$monthCal.ShowTodayCircle = $true      # Circle Todays Date
$monthCal.FirstDayOfWeek = "Sunday"    # Which Day of the Week in the First Column
$monthCal.ScrollChange = 1             # Move number of months at a time with arrows
$monthCal.ShowWeekNumbers = $false     # Show week numbers to the left of each week
$mainForm.Controls.Add($monthCal)

# DateTimePicker
$datePicker = New-Object System.Windows.Forms.DateTimePicker
$datePicker.Location = "18,220"
$datePicker.MinDate = "01/01/2013"       # Minimum Date Dispalyed
$datePicker.MaxDate = "12/31/2013"       # Maximum Date Dispalyed
$mainForm.Controls.Add($datePicker)

# Date Selected Label
$selectLabel = New-Object System.Windows.Forms.Label
$selectLabel.Location = "270,4"
$selectLabel.Height = 22
$selectLabel.Width = 300
$selectLabel.Text = "Date Selected"
$mainForm.Controls.Add($selectLabel)

# MonthCalendar Label
$monthCalendarLabel = New-Object System.Windows.Forms.Label
$monthCalendarLabel.Location = "58,4"
$monthCalendarLabel.Height = 22
$monthCalendarLabel.Width = 300
$monthCalendarLabel.Text = "MonthCalendar Class"
$mainForm.Controls.Add($monthCalendarLabel)

# DateTimePicker Label
$dateTimePickerLabel = New-Object System.Windows.Forms.Label
$dateTimePickerLabel.Location = "56,200"
$dateTimePickerLabel.Height = 22
$dateTimePickerLabel.Width = 300
$dateTimePickerLabel.Text = "DateTimePicker Class"
$mainForm.Controls.Add($dateTimePickerLabel)

# TextBox
$textBox = New-Object System.Windows.Forms.TextBox
$textBox.Location = "270,25"
$textBox.Size = "75,30"
$textBox.ForeColor = "MediumBlue"
$textBox.BackColor = "White"
$mainForm.Controls.Add($textBox)

# Select Button 1
$dateTimePickerButton = New-Object System.Windows.Forms.Button 
$dateTimePickerButton.Location = "270,150"
$dateTimePickerButton.Size = "75,23"
$dateTimePickerButton.ForeColor = "DarkBlue"
$dateTimePickerButton.BackColor = "White"
$dateTimePickerButton.Text = "<<<-- Select"
$dateTimePickerButton.add_Click({
    $textBox.Text = $monthCal.SelectionStart
    $textBox.Text = $textBox.Text.Substring(0,10)
    })
$mainForm.Controls.Add($dateTimePickerButton)

# Select Button 2
$monthlyCalendarButton = New-Object System.Windows.Forms.Button 
$monthlyCalendarButton.Location = "270,220"
$monthlyCalendarButton.Size = "75,23"
$monthlyCalendarButton.ForeColor = "DarkBlue"
$monthlyCalendarButton.BackColor = "White"
$monthlyCalendarButton.Text = "<<<-- Select"
$monthlyCalendarButton.add_Click({
    $textBox.Text = $datePicker.Value
    $textBox.Text = $textBox.Text.Substring(0,10)
    })
$mainForm.Controls.Add($monthlyCalendarButton)

# Exit Button 
$ExitButton = New-Object System.Windows.Forms.Button
$exitButton.Location = "270,60"
$exitButton.Size = "75,23"
$exitButton.ForeColor = "Red"
$exitButton.BackColor = "White"
$exitButton.Text = "Exit"
$exitButton.add_Click({$mainForm.close()})
$mainForm.Controls.Add($exitButton)

[void] $mainForm.ShowDialog()