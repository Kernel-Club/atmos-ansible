# atmos-ansible

Vagrant and Ansible for the on-premise platform of **Atmos**: creates the servers in VirtualBox and configures everything inside them.

```text
Mac (admin: Git, Ansible)
 ├─ SSH ─► host PC (Windows: VirtualBox, Vagrant) ─► vagrant up: creates the VMs
 └─ SSH ─► nexus-traefik  Docker, Nexus, Traefik
           jenkins        Docker, Jenkins
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
| `roles/docker/` | `nexus-traefik`, `jenkins` |
| `roles/nexus/`, `roles/traefik/` | `nexus-traefik`: image registry, HTTPS entry point |
| `roles/jenkins/` | `jenkins`: CI server |
| `roles/k3s/` | `k8s-cp`, `k8s-w1`: k3s cluster, Traefik `HelmChartConfig`, access to the Nexus registry |
| `site.yml` | Configures all servers |

## Prerequisites (manual, once)

| Where | What |
|---|---|
| Host PC (Windows 11) | VirtualBox 7.2.22 and Vagrant 2.4.9, pinned with `winget pin` |
| Host PC | Memory Integrity (Core isolation) off and `bcdedit /set hypervisorlaunchtype off`, so VirtualBox runs without the Windows hypervisor |
| Host PC | OpenSSH Server: key login only (`PasswordAuthentication no`), firewall rule for port 22 only from the Mac, network profile Private |
| Host PC | A clone of this repository (only `git pull`, all changes on the Mac) |
| Mac | Ansible 14.6.0 (core 2.21.6), pinned with `brew pin` |
| Mac | SSH key `~/.ssh/atmos_admin` and the alias `atmos-host` for the host PC in `~/.ssh/config` |

## Usage

```bash
ssh atmos-host "cd atmos-ansible && git pull && vagrant up"      # create and start the servers
ansible-playbook site.yml --ask-vault-pass --ask-become-pass      # configure all servers (from the Mac)
ssh atmos-host "cd atmos-ansible && vagrant halt k8s-w1 k8s-cp jenkins nexus-traefik"   # stop safely
```

Running `site.yml` again changes nothing on a correct server.

**Memory:** about 10.6 GB of the host PC are available for the servers (Windows keeps about 5.2 GB). The application needs only `nexus-traefik`, `k8s-cp` and `k8s-w1` (9 GB), so `jenkins` runs only for CI: `vagrant up jenkins` before a build, `vagrant halt jenkins` after it. With all four servers (11.5 GB) Windows uses its page file: builds are slower, but they finish.

## Rebuild

Restore the `clean` snapshots (or `vagrant destroy` and `vagrant up`) and run `site.yml`. Then follow the manual steps in [architecture.md](https://github.com/Kernel-Club/atmos-dev/blob/develop/docs/on-premise/architecture.md) (section 2): Jenkins credentials and job, first build, Flux bootstrap, Kubernetes Secrets. After a rebuild of `jenkins` alone, set Next Build Number of the job above the highest tag in Nexus.

## Secrets

Platform passwords are stored only encrypted with Ansible Vault. The vault password stays on the Mac; kubeconfig, keys and `.env` files are never committed (see `.gitignore`).

## Related

| Repository | Role |
|---|---|
| [atmos-dev](https://github.com/Kernel-Club/atmos-dev) | Application and on-premise docs (`docs/on-premise/`) |
| [atmos-jenkins](https://github.com/Kernel-Club/atmos-jenkins) | CI pipeline |
| [atmos-k8s](https://github.com/Kernel-Club/atmos-k8s) | Everything inside the cluster: Helm chart, Flux, monitoring |

Branching: `main` + `feature/*` / `fix/*` with a Pull Request ([branching model](https://github.com/Kernel-Club/atmos-dev/blob/develop/docs/on-premise/branching-model.md)).
