<#
.SYNOPSIS
    Creates a vSphere cluster with HA and DRS enabled and adds ESXi hosts.
.NOTES
    Requires VMware.PowerCLI:  Install-Module VMware.PowerCLI -Scope CurrentUser
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$vCenter,
    [string]$Datacenter = 'Homelab',
    [string]$ClusterName = 'Lab-Cluster',
    [string[]]$EsxiHosts = @('esxi01.lab.local', 'esxi02.lab.local', 'esxi03.lab.local')
)

Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false | Out-Null
Connect-VIServer -Server $vCenter

$dc = Get-Datacenter -Name $Datacenter -ErrorAction SilentlyContinue
if (-not $dc) { $dc = New-Datacenter -Location (Get-Folder -NoRecursion) -Name $Datacenter }

$cluster = New-Cluster -Name $ClusterName -Location $dc `
    -HAEnabled -HAAdmissionControlEnabled `
    -DrsEnabled -DrsAutomationLevel FullyAutomated

foreach ($esxi in $EsxiHosts) {
    Write-Host "Adding host $esxi to $ClusterName..." -ForegroundColor Cyan
    Add-VMHost -Name $esxi -Location $cluster -Force -User root -Password (Read-Host "root password for $esxi" -AsSecureString)
}

Write-Host "Cluster '$ClusterName' ready: HA + DRS (FullyAutomated)." -ForegroundColor Green
Disconnect-VIServer -Confirm:$false
