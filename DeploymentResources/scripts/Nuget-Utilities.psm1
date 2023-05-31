function Add-NuGetFeed
{
	[CmdletBinding()]
	param(
		[Parameter()]
		[ValidateNotNullorEmpty()]
		[string]$NuGetFeedName,

		[Parameter()]
		[ValidateNotNullorEmpty()]
		[string]$NuGetFeedUri
	)

	Write-Host "Checking for a PSRepository with source $NuGetFeedUri"

	$repository = Get-PSRepository -Name $NuGetFeedName -ErrorAction SilentlyContinue
	if (-not $repository)
	{
		Write-Host "Registering PSRepository $NuGetFeedName with source $NuGetFeedUri"
		
		# Assure nuget provider is of required minimum version
		Install-PackageProvider -Name NuGet -Scope CurrentUser

		Register-PSRepository -PackageManagementProvider NuGet -Name $NuGetFeedName -Source $NuGetFeedUri -Publish $NuGetFeedUri -InstallationPolicy Trusted -ErrorAction Stop
		Write-Host "Nuget feed $NuGetFeedName has been registered with source location $NuGetFeedUri"
		$repository = Get-PSRepository -Name $NuGetFeedName
		Write-Host "Repository: $repository"
	}
}

#
# Install-NuGetPackage - installs a named module and a minimum version using the specified NuGet feed, the availability of the feed is ensured by a call to the Add-NuGetFeed commandlet.
#
function Install-NuGetPackage
{
	[CmdletBinding()]
	param(
		[Parameter()]
		[ValidateNotNullorEmpty()]
		[string]$NugetFeedName,

		[Parameter()]
		[ValidateNotNullorEmpty()]
		[string]$NugetFeedUri,

		[Parameter()]
		[ValidateNotNullorEmpty()]
		[string]$ModuleName,

		[Parameter()]
		[ValidateNotNullorEmpty()]
		[string]$MinimumVersion
	)
	
	$psVer = "$($PSVersionTable.PSVersion.Major).$($PSVersionTable.PSVersion.Minor)"
	Write-Host "PowerShell version is $psVer"
	$psGet = get-module -Name PowerShellGet -ListAvailable
	if ($psGet -eq $null) { throw "PowerShellGet not available on this machine. PSVer: $psVer" }

	Add-NugetFeed -NuGetFeedName $NugetFeedName -NuGetFeedUri $NugetFeedUri

	Write-Host "Checking for $ModuleName"
	$installed = get-module -Name $ModuleName -ListAvailable
	if (-not $installed)
	{
		Write-Host "Installing $ModuleName ..."
		Install-Module -Name $ModuleName -Repository $NugetFeedName -Scope CurrentUser -Force
		Write-Host "Module $ModuleName installed"
	}
	else
	{
		Write-Host "Looking for update on module $ModuleName"
		Update-Module -Name $ModuleName
		Write-Host "Module $ModuleName updated"
	}

	Write-Host "Checking for $ModuleName"
	$installed = get-module -Name $ModuleName -ListAvailable
	if (-not $installed -or $installed.Version.ToString() -lt $MinimumVersion)
	{
		throw "Module $ModuleName with minimum version $MinimumVersion required for this script to run. Install or update the module and retry."
	}
	else
	{
		Write-Host "Required module $ModuleName found"
	}
}
