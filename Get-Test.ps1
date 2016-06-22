function Get-DomainComputerObjectCountss
{
<#
.SYNOPSIS
Get computer OS types from Active Directory.

.DESCRIPTION
Query AD and get all the computer OS types. Output the counts 

.EXAMPLE
Get-DomainComputerObjectCounts -DaysOldThreshold 45 -DomainController dc01.contoso.com

DESCRIPTION:
Query AD, specifically the dc01.contoso.com DC, for OS types of computers that have reset their password within the last 45 days. 

.PARAMETER DaysOldThreshold
How many days in the past a computer would need to have reset it's password in order to be included in the AD query. 

.PARAMETER DomainController
What Domain Controller in the AD to query. By default, the logon server from which the script is being run from will be used.

.NOTES
Author: Joey Piccola
Last Modified: 03/20/2014
#>

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory)]
        [int]$DaysOldThreshold
        ,
        [Parameter()]
        [string]$DomainController=$env:LOGONSERVER.TrimStart('\\')
    )

    begin {}
    process
    {
        $time = (Get-Date).adddays(-$DaysOldThreshold)
        $OSs = @()
        $active = 0
        Get-ADComputer -Properties operatingSystem,lastlogontimestamp -Server $DomainController -ResultSetSize $null -Filter {lastlogontimestamp -gt $time} | foreach {
		    $OSs += $_.operatingsystem
		    $active++
        }
        $counts = $OSs | group -NoElement | sort count -Descending
        Write-Output $counts
    }
    end {}
}