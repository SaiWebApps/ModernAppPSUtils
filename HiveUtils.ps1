<#
    .SYNOPSIS
    Load a specified hive into the registry.

    .DESCRIPTION
    Given a file such as "settings.dat," load the information within
    the file into the specified registry location.

    .PARAMETER FromFile
    (Required)
    File (e.g, settings.dat) containing subkeys and properties that can be loaded
    into the registry.

    .PARAMETER ToKey
    (Required)
    Path and name of the key under which the given file's contents will be loaded.

    .PARAMETER Verbose
    (Optional)
    If specified, then show output of loading the specified hive into the registry.
    Otherwise, do not print anything to the console.

    .EXAMPLE
    Load-Hive -FromFile $($env:UserProfile + "\AppData\Local\Packages\[App]\Setttings\settings.dat")
        -ToKey "HKLM\[App]Settings" -Verbose
#>
function Load-Hive
{
	Param(
		[Parameter(Mandatory = $True)]
		[string]$FromFile,

		[Parameter(Mandatory = $True)]
		[string]$ToKey
	)

	[string]$output = reg load $ToKey $FromFile
    if ($Verbose) {
        $output
    }
}

<#
    .SYNOPSIS
    Load the given hive into the specified subpath under HKLM.

    .DESCRIPTION
    Load the given hive into the specified subpath under HKLM.
    Essentially, this function is the equivalent of invoking,
    Load-Hive -From $FromFile -ToKey $("HKLM\$ToKey").

    .PARAMETER FromFile
    (Required)
    File (e.g, settings.dat) containing subkeys and properties that 
    can be loaded into the registry.

    .PARAMETER ToKey
    (Required)
    Path and name of the HKLM key under which the given file's contents
    will be loaded.

    .EXAMPLE
    Load-Hive -FromFile $($env:UserProfile + "\AppData\Local\Packages\[App]\Setttings\settings.dat")
        -ToKey "[App]Settings"
#>
function Load-HiveToHKLM
{
    Param(
        [Parameter(Mandatory = $True)]
        [string]$FromFile,

        [Parameter(Mandatory = $True)]
        [string]$ToKey
    )

    [string]$output = Load-Hive -FromFile $FromFile -ToKey "HKLM\$ToKey"
    if ($Verbose) {
        $output
    }
}

<#
    .SYNOPSIS
    Unload the specified hive/key from the registry.

    .DESCRIPTION
    Unload the specified hive/key from the registry.

    .PARAMETER Key
    (Required)
    Registry location/path to hive that we want to unload.

    .PARAMETER Verbose
    (Optional)
    If specified, show output of command to remove/unload the target
    hive from the registry.

    .EXAMPLE
    Unload-Hive -Key "HKLM\[App]Settings" -Verbose
#>
function Unload-Hive
{
	Param(
        [Parameter(Mandatory = $True)]
        [string]$Key
    )

    [string]$output = reg unload $Key
    if ($Verbose) {
        $output
    }
}

<#
    .SYNOPSIS
    Unload the specified hive/key from the registry; the hive/key
    is located under HKLM.

    .DESCRIPTION
    Unload the specified hive/key from the registry.
    Essentially, this function is the equivalent of invoking,
    Unload-Hive -Key $("HKLM\$ToKey").

    .PARAMETER Key
    (Required)
    Registry location/path to hive that we want to unload. This key
    is a subpath under the HKLM key.

    .PARAMETER Verbose
    (Optional)
    If specified, show output of command to remove/unload the target
    hive from the registry.

    .EXAMPLE
    Unload-Hive -Key "HKLM\[App]Settings" -Verbose
#>
function Unload-HiveFromHKLM
{
    Param(
        [Parameter(Mandatory = $True)]
        [string]$Key
    )

    [string]$output = reg unload "HKLM\$Key"
    if ($Verbose) {
        $output
    }
}