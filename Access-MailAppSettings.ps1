# Mail App Global Settings
[string]$MailAppPkgFamily = "microsoft.windowscommunicationsapps_8wekyb3d8bbwe"
[string]$MailAppName = "microsoft.windowscommunicationsapps"

# Supported accent colors
Enum AccentColor
{
    Azure
    Blue
    Gray
    Green
    Magenta
    Orange
    Red
    Teal
    Pink
    Violet
    WindowsAccentColor
}

<#
    .SYNOPSIS
    Install the Mail and Calendar Modern/Universal apps.

    .DESCRIPTION
    Install the Mail and Calendar Modern/Universal apps.

    .EXAMPLE
    Install-MailApp
#>
function Install-MailApp
{
    [string]$installLocation = $(get-appxpackage -AllUsers -Name $MailAppName).installLocation
    [string]$manifestFile = $installLocation + "\Appmanifest.xml"
    Add-AppxPackage -Register $manifestFile -DisableDevelopmentMode
}

<#
    .SYNOPSIS
    Return a RegProperty object containing the information about the
    Mail App property with the given name.

    .DESCRIPTION
    Return a RegProperty object containing the information about the
    Mail App property with the given name.

    .PARAMETER Name
    (Required)
    Name of the target property (e.g., AccentColor)

    .EXAMPLE
    Get-MailAppProperty -Name "AccentColor"
#>
function Get-MailAppProperty
{
    Param(
        [Parameter(Mandatory = $True)]
        [string]$Name
    )

	[string]$loadToRegKey = "MailAppSettings"
    [string]$regSubPath = "LocalState\OutlookSettings"

	. $($PSScriptRoot + "\Access-ModernAppSettings.ps1")
	Get-ModernAppProperty -PackageFamilyName $MailAppPkgFamily -LoadToRegKey $loadToRegKey `
        -RegPathToProperty $regSubPath -PropertyName $Name
}

<#
    .SYNOPSIS
    Set/update the value of the target Mail app property.
    
    .DESCRIPTION
    Set/update the value of the target Mail app property.

    .PARAMETER Name
    (Required)
    Name of the target property (e.g., AccentColor).

    .PARAMETER Value
    (Required)
    New value of target property.

    .PARAMETER Type
    (Optional)
    New data type of target property.

    .EXAMPLE
    Set-MailAppProperty -Name "AccentColor" 
        -Value "06,00,00,00,02,51,69,B6,A6,79,D1,01" 
        -Type "5f5e105"
    --> Sets Mail app accent color to azure.
#>
function Set-MailAppProperty
{
    Param(
        [Parameter(Mandatory = $True)]
        [string]$Name,

        [Parameter(Mandatory = $True)]
        [string]$Value,

        [string]$Type
    )

    [string]$loadToRegKey = "MailAppSettings"
    [string]$regSubPath = "LocalState\OutlookSettings"

    . $($PSScriptRoot + "\Access-ModernAppSettings.ps1")
    Set-ModernAppPropertyValue -PackageFamilyName $MailAppPkgFamily -LoadToRegKey $loadToRegKey `
        -RegPathToProperty $regSubPath -PropertyName $Name -NewValue $Value -PropertyType $Type
}

<#
    .SYNOPSIS
    Change the mail app's accent color the specified color.

    .DESCRIPTION
    Change the mail app's accent color the specified color.

    .PARAMETER To
    (Required)
    A value from the AccentColor enumeration that specifies
    the color to which the Mail app's accent color property
    needs to be set to.

    .EXAMPLE
    Set-MailAppAccentColor -To ([AccentColor]::Blue)
#>
function Set-MailAppAccentColor
{
    Param(
        [Parameter(Mandatory = $True)]
        [AccentColor]$To
    )

    [string]$value = ""

    switch($To) {
        "Azure" { $value = "06,00,00,00,02,51,69,B6,A6,79,D1,01"; break; }
        "Blue" { $value = "00,00,00,00,88,43,C6,A5,A4,79,D1,01"; break; }
        "Gray" { $value = "0A,00,00,00,FE,64,E4,92,A5,79,D1,01"; break; }
        "Green" { $value = "07,00,00,00,48,A0,CD,88,A7,79,D1,01"; break; }
        "Magenta" { $value = "09,00,00,00,49,79,B6,39,A5,79,D1,01"; break; }
        "Orange" { $value = "03,00,00,00,D5,1D,12,D3,A4,79,D1,01"; break;  }
        "Red" { $value = "04,00,00,00,FB,8E,35,15,A5,79,D1,01"; break; }
        "Teal" { $value = "01,00,00,00,64,BE,25,BA,A4,79,D1,01"; break; }
        "Pink" { $value = "02,00,00,00,3D,E3,FF,F6,A4,79,D1,01"; break; }
        "Violet" { $value = "08,00,00,00,0A,C3,3C,7D,A7,79,D1,01"; break; }
        "WindowsAccentColor" { $value = "05,00,00,00,06,CB,96,FE,9F,79,D1,01"; break; }
    }

    Set-MailAppProperty -Name "AccentColor" -Value $value -Type "5f5e105"
}