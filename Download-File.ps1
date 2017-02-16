function Download-File
{
<#
.SYNOPSIS
Download a file from a URL. 
 
.DESCRIPTION
Download a file from a URL and place it in the directory provided.
 
.PARAMETER FileURL
The URL to download the file from including the file name.
 
.PARAMETER FileDestinationDirectory
The preexisting destinatin directory to place the downloaded file in. 

.EXAMPLE
Download-File -FileURL https://artifactory.-.com/artifactory/win-binaries/jfrog.exe -FileDestinationDirectory C:\chocolatey\

Download a file.

.EXAMPLE
Download-File -FileURL https://artifactory.-.com/artifactory/win-binaries/jfrog.exe -FileDestinationDirectory C:\chocolatey\ -ForceOverwrite

Download a file and overwrite the destination file if it already exists.
 
.NOTES
Author: Joey Piccola
Last Modified: 02/16/17
#>
    [CmdletBinding()]
    Param (    
        [Parameter(Mandatory)]
        [string]$FileURL
        ,
        [Parameter(Mandatory)]
        [ValidateScript({Test-Path -Path $_})]
        [string]$FileDestinationDirectory
        ,
        [Parameter()]
        [switch]$ForceOverwrite
    )
 
    begin
    {
        Write-Verbose "Begin function $($MyInvocation.MyCommand.name)"
        $file = Split-Path $FileURL -Leaf
        $path = Join-Path -Path $FileDestinationDirectory -ChildPath $file
        if (!($ForceOverwrite) -and (Test-Path -Path $path))
        {
            Write-Warning "The destination file already exists, use -ForceOverwrite to overwrite the existing directory file."
            break
        }
        else
        {
            Write-Verbose "Destination file already exists: `"$path`""
            Write-Verbose "Overwriting existing file: `"$path`""
        }
    }
    process
    {
        $file = Split-Path $FileURL -Leaf
        $path = Join-Path -Path $FileDestinationDirectory -ChildPath $file
        $wc = New-Object System.Net.WebClient
        $wc.DownloadFile($FileURL,$path)
    }
    end {}
}