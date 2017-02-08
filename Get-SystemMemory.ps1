Function Get-SystemMemory
{
    $memory = $null
    get-ciminstance -class 'cim_physicalmemory' | %{$memory += $_.capacity}
    $memory = $memory/1024/1024
    write-output $memory
}