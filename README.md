# atmos-ansible

Vagrant and Ansible for the on-premise platform of **Atmos**: creates the servers in VirtualBox and configures everything inside them.

```text
Mac (admin: Git, Ansible)
 ├─ SSH ─► host PC (Windows: VirtualBox, Vagrant) ─► vagrant up: creates the VMs
 └─ SSH ─► nexus-traefik  Docker Compose: Nexus, Traefik
           jenkins        Docker Compose: Jenkins
           k8s-cp         k3s server
           k8s-w1         k3s agent
```

## Contents

| Path | What it does |
|---|---|
| `Vagrantfile` | The four VMs: pinned box, CPU, RAM, fixed addresses, SSH key of the Mac, start order |
| `inventory/` | Servers with fixed addresses, plus `localhost` (the Mac) for `/etc/hosts` |
| `group_vars/` | Pinned versions, secrets in Ansible Vault |
| `roles/common/` | All servers: base packages, `ufw`, node-exporter, `*.atmos.lan` hosts entries, swap file outside the cluster |
| `roles/docker/` | `nexus-traefik`, `jenkins`: Docker Engine and the Compose plugin |
| `roles/nexus/`, `roles/traefik/` | `nexus-traefik`: image registry, HTTPS entry point (Compose services) |
| `roles/jenkins/` | `jenkins`: CI server (Compose service) |
| `roles/k3s/` | `k8s-cp`, `k8s-w1`: k3s cluster, Traefik `HelmChartConfig`, access to the Nexus registry |
| `site.yml` | Configures all servers |

## Prerequisites (manual, once)

| Where | What |
|---|---|
| Host PC (Windows 11) | VirtualBox 7.2.22 and Vagrant 2.4.9, pinned with `winget pin` |
| Host PC | Memory Integrity (Core isolation) off and `bcdedit /set hypervisorlaunchtype off`, so VirtualBox runs without the Windows hypervisor |
| Host PC | OpenSSH Server: key login only (`PasswordAuthentication no`), firewall rule for port 22 only from the Mac, network profile Private |
| Host PC | VirtualBox machine folder on drive D: (`VBoxManage setproperty machinefolder "D:\VirtualBox VMs"`); VM disks are dynamic, 64 GB each |
| Host PC | A clone of this repository (only `git pull`, all changes on the Mac) |
| Mac | Ansible 14.6.0 (core 2.21.6), pinned with `brew pin` |
| Mac | SSH key `~/.ssh/atmos_admin` for the host PC and the servers |
| Mac | Ansible Vault password in the macOS Keychain (service `atmos-ansible-vault`), read by `vault-pass.sh` |

## Usage

```bash
# Host PC, in the repository folder (over SSH from the Mac)
git pull && vagrant up                                            # create and start the servers
vagrant halt k8s-w1 && vagrant halt k8s-cp && vagrant halt jenkins && vagrant halt nexus-traefik   # stop in reverse order

# Mac
ansible-playbook site.yml --ask-become-pass                       # configure all servers and the Mac
```

On `nexus-traefik` and `jenkins`, the roles place a `docker-compose.yml` on the server and start it with Docker Compose. Running `site.yml` again changes nothing on a correct server. `vagrant halt` with several names stops them in `Vagrantfile` order, so the reverse order needs one call per server.

**Memory:** the host has about 11 GB available for the servers. The four servers are allocated 11.5 GB, plus about 0.6 GB of VirtualBox overhead; the remaining ~1 GB is served from the host page file (SSD).

## Rebuild

Restore the `clean` snapshots (or `vagrant destroy` and `vagrant up`) and run `site.yml`. Then follow the manual steps in [architecture.md](https://github.com/Kernel-Club/atmos-dev/blob/develop/docs/on-premise/architecture.md) (section 2): Jenkins credentials and job, first build, Flux bootstrap, Kubernetes Secrets. After a rebuild of `jenkins` alone, set Next Build Number of the job above the highest tag in Nexus.

## Secrets

Platform passwords are stored only encrypted with Ansible Vault (`group_vars/all/vault.yml`). The vault password stays in the macOS Keychain of the Mac; `vault-pass.sh` reads it (set in `ansible.cfg`), so no vault password prompt is needed; kubeconfig, keys and `.env` files are never committed (see `.gitignore`).

## Related

| Repository | Role |
|---|---|
| [atmos-dev](https://github.com/Kernel-Club/atmos-dev) | Application and on-premise docs (`docs/on-premise/`) |
| [atmos-jenkins](https://github.com/Kernel-Club/atmos-jenkins) | CI pipeline |
| [atmos-k8s](https://github.com/Kernel-Club/atmos-k8s) | Everything inside the cluster: Helm chart, Flux, monitoring |

Branching: `main` + `feature/*` / `fix/*` with a Pull Request ([branching model](https://github.com/Kernel-Club/atmos-dev/blob/develop/docs/on-premise/branching-model.md)).
