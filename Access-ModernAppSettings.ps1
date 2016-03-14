. $($PSScriptRoot + "\HiveUtils.ps1")

<#
    .SYNOPSIS
    Display a menu with all valid package names, and prompt the user
    to select one.

    .DESCRIPTION
    Use Process-UserSelection function from Process-UserSelection.ps1
    to show all available packages' family names and to prompt the user
    to select one of these names. Return the name selected by the user.
#>
function Prompt-PackageFamilyName
{
    . $($PSScriptRoot + "\Process-UserSelection.ps1")

    [array]$modernAppPkgs = get-appxpackage | % { $_.PackageFamilyName }
    [string]$title = "Select one of the following packages"
    [string]$prompt = "Enter Pkg #"
    Process-UserSelection -AvailableChoices $modernAppPkgs -Title $title -Prompt $prompt
}

<#
    .SYNOPSIS
    Return the path to the settings hive file for the specified Modern app.

    .DESCRIPTION
    Return the path to the settings hive file for the specified Modern app.
    
    .PARAMETER PackageFamilyName
    (Optional)
    - If no PackageFamilyName is specified OR it is invalid, then prompt 
    the user to select 1 from a list of all available package family names. 
    Return the settings hive file path for the selected package.
    - If specified, then just return the settings hive file for the 
    specified package.
#>
function Get-ModernAppSettingsPath
{
    Param(
        [string]$PackageFamilyName
    )

    [string]$prefix = $env:UserProfile + "\AppData\Local\Packages\"
    [string]$suffix = "\Settings\settings.dat"
    [string]$settingsPath = $prefix + $PackageFamilyName + $suffix

    # Prompt if user did not specify PackageFamilyName OR 
    # PackageFamilyName is invalid.
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

<#
    .SYNOPSIS
    Create a new RegProperty Object to store details about a registry property.

    .DESCRIPTION
    Create a new RegProperty Object to store details about a registry property.

    .PARAMETER Name
    (Optional, default = NULL)
    Name of the registry property.

    .PARAMETER Value
    (Optional, default = NULL)
    Value of the registry property.

    .PARAMETER DataType
    (Optional, default = NULL)
    Data type of the registry property.
#>
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

<#
    .SYNOPSIS
    Return a RegProperty object containing details about the specified 
    property for the given Modern app.

    .DESCRIPTION
    Return a RegProperty object containing details about the specified 
    property for the given Modern app.

    .PARAMETER LoadToRegKey
    (Required)
    Load the specified Modern app's settings hive file to this registry
    key under HKLM.

    .PARAMETER RegPathToProperty
    (Required)
    Path under LoadToRegKey that leads to the key with the target property.

    .PARAMETER PropertyName
    (Required)
    Name of the property that we want details about for the specified Modern app.

    .PARAMETER PackageFamilyName
    (Optional)
    Package family name of the Modern app that contains the target property.
#>
function Get-ModernAppProperty
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

<#
    .SYNOPSIS
    Update the value of the specified property in the given modern app.

    .DESCRIPTION
    Update the value of the specified property in the given modern app.

    .PARAMETER LoadToRegKey
    (Required)
    Load the specified Modern app's settings hive file to this registry
    key under HKLM.

    .PARAMETER RegPathToProperty
    (Required)
    Path under LoadToRegKey that leads to the key with the target property.

    .PARAMETER PropertyName
    (Required)
    Name of the property that we want to update for the specified Modern app.

    .PARAMETER NewValue
    Change the value of the target property to this value.

    .PARAMETER PropertyType
    (Optional)
    Change the data type of the target property to the value in this parameter.

    .PARAMETER PackageFamilyName
    (Optional)
    Package family name of the Modern app that contains the target property.
#>
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
        # If the user specified an actual property type, then we can't safely use reg add since
        # this value could be an unsupported type (e.g., hex value or REG_NONE). So, use a .reg
        # file instead.
        if ($PropertyType) {
            [string]$noneRegPath = $($PSScriptRoot + "\none.reg")

            echo "Windows Registry Editor Version 5.00`n" > $noneRegPath
            echo $("[HKEY_LOCAL_MACHINE\" + $fullRegKeyPath + "]`n") >> $noneRegPath
            echo $("`"" + $PropertyName + "`"=hex(" + $PropertyType + "):" + $NewValue) >> $noneRegPath
            reg import $noneRegPath
            del $noneRegPath
        }
        # Otherwise, if the user didn't specify a property type, get the current property type,
        # and simply maintain it.
        else {
            [string]$type = $(Get-ModernAppPropertyValue -PackageFamilyName $PackageFamilyName `
                -PropertyName $PropertyName -RegPathToProperty $RegPathToProperty -LoadToRegKey $LoadToRegKey).DataType
            reg add "HKLM\$fullRegKeyPath" /v $PropertyName /d $NewValue /t $type /f
        }
    }
}