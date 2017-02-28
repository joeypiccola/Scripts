function Get-ClusterDatastoreClusters
{
	param
	(
        [CmdletBinding()]		
        [Parameter(Mandatory)]
		[string]$Cluster
        , 
        [Parameter()]
		[string]$HostsSampleSize=1
	)

    begin
    {
        # verify we can connect to the provided cluster
        if (!($GetCluster = Get-Cluster -Name $Cluster))
        {
            Write-Verbose "Unable to connect to `"$Cluster`""
            break
        }
    }
    process
    {
        $vmhosts = $GetCluster | Get-VMHost | ?{$_.ConnectionState -eq 'Connected'} | Get-Random -Count $HostsSampleSize
        $vmhosts | %{Write-Verbose "Using `"$($_.name)`" as sample host"}

        $StoragePodsParents = @()
        # var used for tracking how many datastores were found across hosts to then verify against other hosts
        $hostsDataStoreCount = @()
        foreach ($vmhost in $vmhosts)
        {
            $hostDatastores = $null
            # get the datastores on the host
            $hostDatastores = Get-Datastore -VMHost $vmhost
            $hostsDataStoreCount += $hostDatastores.count
            Write-Verbose "Found $($hostDatastores.count)x datastores on $($vmhost).name"
            # look at each host datastore where the datastore parent is a StoragePod
            foreach ($hostDatastore in $hostDatastores)
            {
                $StoragePodsParents += $hostDatastore.extensiondata.parent | ?{$_.type -eq 'storagepod'}
            }
        }
        
        # provide some best effort validation that the hosts queried provided consistent datastore info
        if (($hostsDataStoreCount | sort -Unique).count -ne 1)
        {
            Write-Warning "Available datastores found across $HostsSampleSize`x hosts to not match!"
        }
        else
        {
            Write-Verbose "Available datastores found across $HostsSampleSize`x hosts match!"
        }

        # sort out all the unique StoragePods Found
        $ClusterStoragePods = @()
        $StoragePods = ($StoragePodsParents | Sort-Object -Unique).value
        
        # for each storage pod found, build the datastore cluster ID and get it (e.g. StoragePod-group-pXXXX)
        foreach ($StoragePod in $StoragePods)
        {
            $stString = "StoragePod-$StoragePod"
            $ClusterStoragePods += (Get-DatastoreCluster -Id $stString)
        }
        Write-Output $ClusterStoragePods
    }
    end {}
}