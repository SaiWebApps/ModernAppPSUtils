<#
    .SYNOPSIS
    Manage the scheduled task/job that randomly selects a new accent color
    for the Windows Mail App.

    .DESCRIPTION
    Manage the scheduled task/job that randomly selects a new accent color
    for the Windows Mail App.

    .PARAMETER Create
    If specified, then create a task to randomly select a new accent color
    for the Windows Mail App at midnight on a daily basis.

    .PARAMETER Delete
    If specified, then delete the task, "Randomize-MailAppAccentColor," which
    was previously created by invoking this script with the "Create" switch.

    .PARAMETER Run
    If specified, then run the task. Meant for testing/debugging purposes.

    .EXAMPLE
    .\Manage-RandomizeAccentColorJob.ps1 -Create
    .\Manage-RandomizeAccentColorJob.ps1 -Run
    .\Manage-RandomizeAccentColorJob.ps1 -Delete
#>
[CmdletBinding(DefaultParameterSetName = "Create")]
Param(
    [Parameter(ParameterSetName = "Create", Mandatory = $True)]
    [switch]$Create,

    [Parameter(ParameterSetName = "Delete", Mandatory = $True)]
    [switch]$Delete,

    [Parameter(ParameterSetName = "Run", Mandatory = $True)]
    [switch]$Run
)

function Create-Job
{
    [string]$TaskFrequency = "daily"
    [string]$StartTime = "00:00"    # Midnight
    
    # Build the task command.
    # The command involves opening a PowerShell window, importing the 
    # Access-MailAppAccentColor script, and then invoking the 
    # Randomize-MailAppAccentColor function with the Set switch.
    [System.Text.StringBuilder]$Task = New-Object -TypeName "System.Text.StringBuilder"
    $Task.Append("`"")
    $Task.Append("powershell -command 'Import-Module ")
    $Task.Append($PSScriptRoot + "\Access-MailAppAccentColor.ps1; ");
    $Task.Append("Randomize-MailAppAccentColor -Set'")
    $Task.Append("`"")

    # /rl HIGHEST ensures that we execute this task with highest privilege
    # (necessary since we're dealing with the registry, etc.).
    schtasks /create /tn $TaskName /sc $TaskFrequency /st $StartTime /tr $Task.ToString() /rl HIGHEST /f
}

function Run-Job
{
    schtasks /run /tn $TaskName
}

function Delete-Job
{
    schtasks /delete /tn $TaskName /f
}

[string]$TaskName = "Randomize-MailAppAccentColor"
if ($Create) {
    Create-Job
}
elseif ($Run) {
    Run-Job
}
elseif ($Delete) {
    Delete-Job
}