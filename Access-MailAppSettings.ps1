[string]$MailAppPkgFamily = "microsoft.windowscommunicationsapps_8wekyb3d8bbwe"

function Get-MailAppProperty
{
    Param(
        [Parameter(Mandatory = $True)]
        [string]$Name
    )

	[string]$loadToRegKey = "HKLM\MailAppSettings"
    [string]$regSubPath = "LocalState\OutlookSettings"

	. $($PSScriptRoot + "\Access-ModernAppSettings.ps1")
	Get-ModernAppPropertyValue -PackageFamilyName $MailAppPkgFamily -LoadToRegKey $loadToRegKey -RegPathToProperty $regSubPath -PropertyName $Name
}