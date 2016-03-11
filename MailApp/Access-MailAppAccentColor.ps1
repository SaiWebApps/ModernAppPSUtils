. $($PSScriptRoot + "\Access-MailAppSettings.ps1")

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
    Return the Mail app's current accent color.

    .DESCRIPTION
    Return a string with the AccentColor value corresponding to the
    Mail app's AccentColor registry property. If the registry property
    does not map to any of the AccentColor enum values, then throw an
    error, stating that we are currently dealing with an unsupported
    AccentColor.
#>
function Get-MailAppAccentColor
{
    [string]$rawValue = $(Get-MailAppProperty -Name "AccentColor").Value
    [string]$accentColor = "Unsupported Accent Color - $rawValue"

    switch($rawValue) {
        "06000000025169B6A679D101" { $accentColor = ([AccentColor]::Azure); break; }
        "000000008843C6A5A479D101" { $accentColor = ([AccentColor]::Blue); break; }
        "0A000000FE64E492A579D101" { $accentColor = ([AccentColor]::Gray); break; }
        "0700000048A0CD88A779D101" { $accentColor = ([AccentColor]::Green); break; }
        "090000004979B639A579D101" { $accentColor = ([AccentColor]::Magenta); break; }
        "03000000D51D12D3A479D101" { $accentColor = ([AccentColor]::Orange); break; }
        "04000000FB8E3515A579D101" { $accentColor = ([AccentColor]::Red); break; }
        "0100000064BE25BAA479D101" { $accentColor = ([AccentColor]::Teal); break; }
        "020000003DE3FFF6A479D101" { $accentColor = ([AccentColor]::Pink); break; }
        "080000000AC33C7DA779D101" { $accentColor = ([AccentColor]::Violet); break; }
        "0500000006CB96FE9F79D101" { $accentColor = ([AccentColor]::WindowsAccentColor); break; }
        default { throw $accentColor; break; }
    }

    return $accentColor
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