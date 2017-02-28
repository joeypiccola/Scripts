#$pod = Get-Cluster las1-vc-entsvc | Get-Datastore | ?{$_.ParentFolderId -like 'StoragePod-group-*'} | sort -Unique -Property ParentFolderID
#Get-DatastoreCluster -Id $pod.ParentFolderId

function Get-ClusterDatastoreClusters
{
	param
	(
        [CmdletBinding()]		
        [Parameter(Mandatory)]
		[string]$Cluster
	)

    begin
    {
        # verify we can connect to the provided cluster.
        if (!($GetCluster = Get-Cluster -Name $Cluster))
        {
            Write-Verbose "Unable to connect to `"$Cluster`""
            break
        }
    }
    process
    {
        $pods = Get-Cluster $Cluster | Get-Datastore | ?{$_.ParentFolderId -like 'StoragePod-group-*'} | sort -Unique -Property ParentFolderID
        Write-Verbose "Found $($pods.count)x datastore cluster on $cluster cluster."
        foreach ($pod in $pods)
        {
            $GetPod = Get-DatastoreCluster -Id $pod.ParentFolderId
            Write-Output $GetPod
        }
    }
    end
    {
    
    }
}