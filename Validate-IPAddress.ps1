function Validate-IPAddress
{
	param
	(
		[Parameter()]
		[string]$IPAddress
	)
	if ($IPAddress -as [ipaddress])
	{
		Write-Output $true
	}
	else
	{
		Write-Output $false
	}
}