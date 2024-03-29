function Add-HttpServerHeader
{
	<#
	.SYNOPSIS 
	Adds a custom HTTP header to all sites in IIS.

	.DESCRIPTION
	This function adds a custom HTTP header to all sites in IIS. The header name and value can be specified as parameters, but by default, the header name is "Server" and the header value is the computer name.

	.PARAMETER HeaderName
	Specifies the name of the custom HTTP header. Default value is "Server".

	.PARAMETER HeaderValue
	Specifies the value of the custom HTTP header. Default value is the computer name.

	.EXAMPLE
	Add-HttpServerHeader -Verbose
	Adds the default custom HTTP header to all sites in IIS, displaying verbose output.

	.NOTES
	This function requires the WebAdministration module to be imported. If the header already exists for a site, it will be removed and then added with the new value.

	#>
	[CmdletBinding()]
	param
	(
		[Parameter(Mandatory = $false)]
		[string]$HeaderName = "Server",

		[Parameter(Mandatory = $false)]
		[string]$HeaderValue = $env:COMPUTERNAME
	) # param
	process
	{
		try
		{
			Import-Module WebAdministration -ErrorAction Stop
			# Retrieve all sites from IIS
			$sites = Get-ChildItem IIS:\Sites
			
			foreach ($site in $sites)
			{
				$siteName = $site.Name
				Write-Verbose "Processing site: $siteName"
				
				# Check if the header already exists and remove it
				$headerExists = Get-WebConfigurationProperty -pspath "MACHINE/WEBROOT/APPHOST" -location $siteName -filter "system.webServer/httpProtocol/customHeaders" -name "." | 
					Where-Object { $_.name -eq $HeaderName }

				if ($headerExists)
				{
					Write-Verbose "Header $HeaderName already exists for $siteName. Removing existing header."
					Remove-WebConfigurationProperty -pspath "MACHINE/WEBROOT/APPHOST" -location $siteName -filter "system.webServer/httpProtocol/customHeaders" -name "." -AtElement @{name=$HeaderName}
				}

				# Add the new header
				Add-WebConfigurationProperty -pspath "MACHINE/WEBROOT/APPHOST" -location $siteName -filter "system.webServer/httpProtocol/customHeaders" -name "." -value @{name=$HeaderName;value=$HeaderValue}
				Write-Verbose "Added header $HeaderName with value $HeaderValue to $siteName."
			} # foreach ($site in $sites)
		} # try
		catch
		{
			Write-Error "An error occurred: $_"
		} # catch
	} # process
} # function Add-HttpServerHeader
