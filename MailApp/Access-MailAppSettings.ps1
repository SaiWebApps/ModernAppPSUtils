. $($PSScriptRoot + "\..\Access-ModernAppSettings.ps1")


# Mail App Global Settings
[string]$MailAppPkgFamily = "microsoft.windowscommunicationsapps_8wekyb3d8bbwe"
[string]$MailAppName = "microsoft.windowscommunicationsapps"

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

    Set-ModernAppPropertyValue -PackageFamilyName $MailAppPkgFamily -LoadToRegKey $loadToRegKey `
        -RegPathToProperty $regSubPath -PropertyName $Name -NewValue $Value -PropertyType $Type
}