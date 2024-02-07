[CmdletBinding()]
param()
process
{
	<#
	.SYNOPSIS
	This script retrieves the security token for each web application in the SharePoint farm.

	.DESCRIPTION
	The script iterates through each web application in the SharePoint farm and retrieves the security token for the default zone. It uses the SharePoint Server Object Model to access the necessary classes and methods.

	.PARAMETER None
	This script does not accept any parameters.

	.EXAMPLE
	.\Test-STStoken.ps1
	Runs the script and retrieves the security token for each web application in the SharePoint farm.

	.NOTES
	- This script requires the Microsoft.SharePoint.PowerShell snap-in to be loaded.
	- The script assumes that it is being run on a SharePoint server.
	#>

	try
	{
		# Load the SharePoint PowerShell snap-in
		Add-PSSnapin Microsoft.SharePoint.PowerShell

		# Get the local SharePoint farm
		$SPFarm = [Microsoft.SharePoint.Administration.SPFarm]::Local

		# Create a collection of SharePoint web services
		$SPWebServiceCollection = New-Object Microsoft.SharePoint.Administration.SPWebServiceCollection($SPFarm)

		# Iterate through each web service
		foreach ($SPWebService in $SPWebServiceCollection)
		{
			# Iterate through each web application in the web service
			foreach ($SPWebApp in $SPWebService.WebApplications)
			{
				# Get the response URI for the default zone of the web application
				$SPContext = $SPWebApp.GetResponseUri([Microsoft.SharePoint.Administration.SPUrlZone]::Default)

				# Call the token generator function to retrieve the security token
				$SecurityToken = [Microsoft.SharePoint.SPSecurityContext]::SecurityTokenForContext($SPContext)

				# Output the web application context and the security token
				[PSCustomObject]@{
					"Web Application Context" = $SPContext.AbsoluteUri
					Token = $SecurityToken.InternalTokenReference
				} # [PSCustomObject]@{...}
			} # foreach ($SPWebApp in $SPWebService.WebApplications)
		} # foreach ($SPWebService in $SPWebServiceCollection)
	} # process
	catch
	{
		# Handle any exceptions and display a warning message
		Write-Warning ($_.Exception.Message)
	} # catch
} # End of process
