<#
    Schedule a task that will randomly select a new accent color the Mail app at
    midnight on a daily basis.
#>

Schtasks /create /tn "Randomize-MailAppAccentColor" /sc daily /st 00:00 `
    /tr "PowerShell -command {. '.\Access-MailAppAccentColor.ps1'; Randomize-MailAppAccentColor -Set}"