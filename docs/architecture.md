# VMware Homelab Architecture

## Hosts
| Host         | Role            | CPU      | RAM   | Storage          |
|--------------|-----------------|----------|-------|------------------|
| esxi01-03    | ESXi 8.0 nodes  | 8c each  | 64 GB | NVMe (vSAN disk) |
| vcsa.lab     | vCenter Server  | n/a      | n/a   | n/a              |

## Cluster services
- **HA**, VM restart on host failure; admission control enabled.
- **DRS**, FullyAutomated load balancing + initial placement.
- **vMotion**, dedicated VMkernel on VLAN20; live migration tested under load.
- **vSAN**, 3-node hyperconverged datastore from local NVMe.

## Networking (distributed switch)
| Port group   | VLAN | Purpose              |
|--------------|------|----------------------|
| MGMT         | 20   | ESXi management      |
| vMotion      | 20   | vMotion VMkernel     |
| vSAN         | 25   | vSAN traffic         |
| VLAN30-Lab   | 30   | Lab VM workloads     |

## Operational drills practiced
- Host maintenance mode → DRS evacuates VMs automatically.
- Simulated host failure → HA restarts VMs on surviving hosts.
- Snapshot + revert workflow before risky changes.
- Template-based provisioning via `powercli/New-LabVM.ps1`.
