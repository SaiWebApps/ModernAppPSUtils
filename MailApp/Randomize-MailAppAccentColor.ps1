<#
    .SYNOPSIS
    Randomly select a value from the AccentColor enumeration defined
    in Access-MailAppAccentColor.ps1. Set the mail app's accent color
    to that value if the Set switch is specified.

    .DESCRIPTION
    Randomly select a value from the AccentColor enumeration defined
    in Access-MailAppAccentColor.ps1. Set the mail app's accent color
    to that value if the Set switch is specified.

    .PARAMETER Set
    (Optional)
    Specifies whether we should set the Mail app's accent color to one
    of the randomly selected AccentColor enum values.    
#>
Param(
    [switch]$Set
)

. $($PSScriptRoot + "\Access-MailAppAccentColor.ps1")

[int]$numValues = [Enum]::GetValues([AccentColor]).Count
[AccentColor]$randomColor = Get-Random -Minimum 0 -Maximum $numValues

if ($Set) {
    Set-MailAppAccentColor -To $randomColor
}
return $randomColor