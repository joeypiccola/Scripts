function Validate-Integer
{
	param
	(
		[Parameter()]
		[string]$Integer
	)
	if ($Integer -match "^[\d\.]+$")
	{
		Write-Output $true
	}
	else
	{
		Write-Output $false
	}
}