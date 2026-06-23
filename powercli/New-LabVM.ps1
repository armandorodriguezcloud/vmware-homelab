<#
.SYNOPSIS
    Clones a templated VM onto the least-loaded host in the cluster.
.EXAMPLE
    .\New-LabVM.ps1 -vCenter vcsa.lab.local -Name web01 -Template ubuntu-22.04-tmpl
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$vCenter,
    [Parameter(Mandatory)][string]$Name,
    [Parameter(Mandatory)][string]$Template,
    [string]$Cluster = 'Lab-Cluster',
    [string]$Datastore = 'vsanDatastore',
    [string]$Network = 'VLAN30-Lab'
)

Connect-VIServer -Server $vCenter | Out-Null

# pick the host with the most free memory
$target = Get-Cluster $Cluster | Get-VMHost |
    Sort-Object { $_.MemoryTotalGB - $_.MemoryUsageGB } -Descending |
    Select-Object -First 1

$vm = New-VM -Name $Name -Template $Template -VMHost $target -Datastore $Datastore
$vm | Get-NetworkAdapter | Set-NetworkAdapter -NetworkName $Network -Confirm:$false
$vm | Start-VM

Write-Host "Deployed $Name on $($target.Name)." -ForegroundColor Green
Disconnect-VIServer -Confirm:$false
