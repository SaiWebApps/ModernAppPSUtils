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

function Load-HiveToHKLM
{
    Param(
        [Parameter(Mandatory = $True)]
        [string]$FromFile,

        [Parameter(Mandatory = $True)]
        [string]$ToKey
    )

    Load-Hive -FromFile $FromFile -ToKey "HKLM\$ToKey"
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
    If specified, show output of command to remove/unload the target hive from the registry.

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

function Prompt-PackageFamilyName
{
    . $($PSScriptRoot + "\Process-UserSelection.ps1")

    [array]$modernAppPkgs = get-appxpackage | % { $_.PackageFamilyName }
    [string]$title = "Select one of the following packages"
    [string]$prompt = "Enter Pkg #"
    Process-UserSelection -AvailableChoices $modernAppPkgs -Title $title -Prompt $prompt
}

function Get-ModernAppSettingsPath
{
    Param(
        [string]$PackageFamilyName
    )

    [string]$prefix = $env:UserProfile + "\AppData\Local\Packages\"
    [string]$suffix = "\Settings\settings.dat"
    [string]$settingsPath = $prefix + $PackageFamilyName + $suffix

    if (!$PackageFamilyName -or !(Test-Path $settingsPath)) {
        $PackageFamilyName = Prompt-PackageFamilyName
        $settingsPath = $prefix + $PackageFamilyName + $suffix
    }

    return $settingsPath
}

<#
    .SYNOPSIS
    Access the specified modern/universal app's settings.

    .DESCRIPTION
    Load the given modern app's settings into the registry, execute the
    given function, and then unload the app's settings from the registry.

    .PARAMETER ToRegKey
    (Required)
    Registry location/path into which the given modern app's settings will
    be loaded.

    .PARAMETER ExecuteFunction
    (Required)
    Function to execute after loading the specified modern app's settings
    into the registry.

    .PARAMETER PackageFamilyName
    (Optional)
    Name of the folder containing the modern app's settings in the local filesystem.
    Will load settings from this folder into the registry.
    If the user does not specify a valid PackageFamilyName, then display all valid
    PackageFamilyName values, and prompt the user to select one.

    .EXAMPLE
    Access-ModernAppSettings -ToRegKey "HKLM\ModernAppSettings" -ExecuteFunction {reg query "HKLM\ModernAppSettings"}
    -> Enter interactive mode, display all valid package family names, and prompt the user to select one.
       Process user selection, load specified app's settings into registry into the key "HKLM\ModernAppSettings,"
       and list subkeys/properties under HKLM\ModernAppSettings. Ultimately, unload ModernAppSettings from HKLM.
#>
function Access-ModernAppSettings
{
    Param(
        [Parameter(Mandatory = $True)]
        [string]$ToRegKey,

        [Parameter(Mandatory = $True)]
        [scriptblock]$ExecuteFunction,

        [string]$PackageFamilyName
    )

    [string]$settingsFilePath = Get-ModernAppSettingsPath -PackageFamilyName $PackageFamilyName
    Load-HiveToHKLM -FromFile $settingsFilePath -ToKey $ToRegKey
    Invoke-Command $ExecuteFunction
    Unload-HiveFromHKLM -Key $ToRegKey
}

function New-RegProperty
{
    Param(
        [string]$Name = $NULL,
        [string]$Value = $NULL,
        [string]$DataType = $NULL
    )

    [object]$output = New-Object -TypeName PSObject
    Add-Member -InputObject $output -MemberType NoteProperty -Name Name -Value $Name     
    Add-Member -InputObject $output -MemberType NoteProperty -Name Value -Value $Value
    Add-Member -InputObject $output -MemberType NoteProperty -Name DataType -Value $DataType
    return $output
}

function Get-ModernAppPropertyValue
{
    Param(
        [Parameter(Mandatory = $True)]
        [string]$LoadToRegKey,

        [Parameter(Mandatory = $True)]
        [string]$RegPathToProperty,

        [Parameter(Mandatory = $True)]
        [string]$PropertyName,

        [string]$PackageFamilyName
    )

    Access-ModernAppSettings -PackageFamilyName $PackageFamilyName -ToRegKey $LoadToRegKey -ExecuteFunction {
        [object]$output = New-RegProperty

        [string]$regQueryOutput = reg query $("HKLM\" + $LoadToRegKey + "\" + $RegPathToProperty) /v $PropertyName
        [array]$tokenizeRegQueryOutput = $regQueryOutput.Split(" ") | ? { $_ }
        if ($tokenizeRegQueryOutput.Length -ge 4) {
            $output.Name = $tokenizeRegQueryOutput[1]
            $output.Value = $tokenizeRegQueryOutput[3]
            $output.DataType = $tokenizeRegQueryOutput[2]
        }

        return $output
    }
}

function Set-ModernAppPropertyValue
{
    Param(
        [Parameter(Mandatory = $True)]
        [string]$LoadToRegKey,

        [Parameter(Mandatory = $True)]
        [string]$RegPathToProperty,

        [Parameter(Mandatory = $True)]
        [string]$PropertyName,

        [Parameter(Mandatory = $True)]
        [string]$NewValue,

        [string]$PropertyType,

        [string]$PackageFamilyName
    )

    [string]$fullRegKeyPath = $LoadToRegKey + "\" + $RegPathToProperty

    Access-ModernAppSettings -PackageFamilyName $PackageFamilyName -ToRegKey $LoadToRegKey -ExecuteFunction {
        if ($PropertyType) {            
            echo "Windows Registry Editor Version 5.00`n" > none.reg
            echo $("[HKEY_LOCAL_MACHINE\" + $fullRegKeyPath + "]`n") >> none.reg
            echo $("`"" + $PropertyName + "`"=hex(" + $PropertyType + "):" + $NewValue) >> none.reg
            reg import none.reg
            del none.reg
        }
        else {
            [string]$type = $(Get-ModernAppPropertyValue -PackageFamilyName $PackageFamilyName `
                -PropertyName $PropertyName -RegPathToProperty $RegPathToProperty -LoadToRegKey $LoadToRegKey).DataType
            reg add "HKLM\$fullRegKeyPath" /v $PropertyName /d $NewValue /t $type /f
        }
    }
}