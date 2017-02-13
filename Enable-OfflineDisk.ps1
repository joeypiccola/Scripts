Function Enable-OfflineDisk
{ 
    
    # for this to work on 08, diskpart's SAN policy must be set to 'OfflineShared'
    # this can be done by opening diskpart, typing SAN to view the current setting then 'SAN policy=offlineshared' to change it.
    
    #Check for offline disks on server. 
    $offlinedisk = "list disk" | diskpart | where {$_ -match "offline"} 
    #If offline disk(s) exist 
    if($offlinedisk.count -eq 1) 
    { 
        Write-Output "Following Offline disk(s) found..Trying to bring Online." 
        $offlinedisk 
         
        #for all offline disk(s) found on the server 
        foreach($offdisk in $offlinedisk) 
        { 
     
            $offdiskS = $offdisk.Substring(2,6) 
            Write-Output "Enabling $offdiskS" 
#Creating command parameters for selecting disk, making disk online and setting off the read-only flag. 
$OnlineDisk = @" 
select $offdiskS
attributes disk clear readonly
online disk
select $offdiskS
clean
convert gpt
create partition primary
format quick fs=ntfs label="Data" unit=4096
assign letter="D"
"@ 
            #Sending parameters to diskpart 
            $noOut = $OnlineDisk | diskpart 
            sleep 5 
     
       } 
 
        #If selfhealing failed throw the alert. 
        if(($offlinedisk = "list disk" | diskpart | where {$_ -match "offline"} )) 
        { 
         
            Write-Output "Failed to bring the following disk(s) online" 
            $offlinedisk 
 
        } 
        else 
        { 
     
            Write-Output "Disk(s) are now online." 
 
        } 
 
    }
    elseif ($offlinedisk.count -gt 1)
    {
        Write-Output "Following Offline disk(s) found..Trying to bring Online." 
        $offlinedisk 
         
        #for all offline disk(s) found on the server 
        foreach($offdisk in $offlinedisk) 
        { 
     
            $offdiskS = $offdisk.Substring(2,6) 
            Write-Output "Enabling $offdiskS" 
#Creating command parameters for selecting disk, making disk online and setting off the read-only flag. 
$OnlineDisk = @" 
select $offdiskS
attributes disk clear readonly
online disk
select $offdiskS
clean
convert gpt
create partition primary
format quick fs=ntfs label="Data" unit=4096
"@ 
            #Sending parameters to diskpart 
            $noOut = $OnlineDisk | diskpart 
            sleep 5 
     
       } 
 
        #If selfhealing failed throw the alert. 
        if(($offlinedisk = "list disk" | diskpart | where {$_ -match "offline"} )) 
        { 
         
            Write-Output "Failed to bring the following disk(s) online" 
            $offlinedisk 
 
        } 
        else 
        { 
     
            Write-Output "Disk(s) are now online." 
 
        }    
    
    } 
 
    #If no offline disk(s) exist. 
    else 
    { 
 
        #All disk(s) are online. 
        Write-Host "All disk(s) are online!" 
 
    } 
}