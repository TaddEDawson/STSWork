Find-Module PowerStig | Install-Module -Force -AllowClobber -Verbose -Scope CurrentUser -SkipPublisherCheck

Import-Module PowerStig -Force -Verbose

$Stig = Get-Stig -Technology WindowsServer | Out-GridView -PassThru

Get-StigVersionNumber 