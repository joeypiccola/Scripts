﻿function Copy-Files
{
<#
.SYNOPSIS
Copy files from a source to a destination with a log file. 
 
.DESCRIPTION
Copy files from a source to a destinaion via robocopy. Do so by launching
a new powershell window that runs synchronous to the process used to run
this function. This function does not provide any error handeling for 
robocopy. It assumes checks have already been performed to ensure its success
in accessing both the source and destination file shares!! Leverage the
robocopy parameters in the function. 
 
.PARAMETER Source
The source directory to copy. 
 
.PARAMETER Destination
The destination directory to copy the files to.
 
.PARAMETER LogDirectory
The directory to create the log file in.
 
.EXAMPLE
Copy-Files -Source '\\file01.contoso.com\home\fkline' -Destination '\\file02.ollie.contoso.com\home\fkline' -LogsDirectory 'c:\logs\fileMoves'
 
Provide a source and a destination to copy files. Create logs in the directory provided.
 
.NOTES
Author: Joey Piccola
Last Modified: 07/23/15
- setup /MT
- setup param to include excluded files and or dir
- setup to work just on files
- option to not copy /XD $RECYCLE.BIN "System Volume Information"

#>
 
    [CmdletBinding()]
    Param (    
        [Parameter(Mandatory)]
        [ValidateScript({Test-Path -Path $_})]
        [string]$Source
        ,
        [Parameter(Mandatory)]
        [ValidateScript({Test-Path -Path $_})]
        [string]$Destination
        ,
        [Parameter(Mandatory)]
        [ValidateScript({Test-Path -Path $_})]
        [string]$LogDirectory
    )
 
    begin {Write-Verbose "Begin function $($MyInvocation.MyCommand.name)"}
    process
    {
        $robotool = 'C:\Windows\System32\Robocopy.exe'
        $SourceLog = Split-Path ($Source -replace '[:]') -Leaf
        $DestinationLog = Split-Path ($Destination -replace '[:]') -Leaf
        if (Test-Path -Path $robotool)
        {
            Write-Verbose "Starting copy: $(Get-Date)"
            $LogFile = Join-Path -Path $LogDirectory -ChildPath "$SourceLog`_to_$DestinationLog`_$(Get-Date -Format MMddyy-hhmmss).txt"
            $notes = "Source: $Source`nDestination: $Destination`nLog file: $LogFile"
            Write-Verbose $notes
            $params = "/e /z /W:1 /R:1 /LOG:`"$LogFile`""
            start powershell -ArgumentList "write-host 'Start: $(get-date)`n$notes';measure-command {$robotool $Source $Destination $params};Write-Host 'Stop`n$notes'; pause"
        }
        else
 
        {
            Write-Warning "Robocopy.exe not found in `"$robotool`""
        }
    }
    end {Write-Verbose "End function $($MyInvocation.MyCommand.name)"}
}