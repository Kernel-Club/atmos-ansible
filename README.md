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
| `Vagrantfile` | The four VMs: box, CPU, RAM, disk, fixed addresses, SSH key of the Mac |
| `inventory/` | Servers with fixed addresses, plus `localhost` (the Mac) for `/etc/hosts` |
| `group_vars/` | Pinned versions, secrets in Ansible Vault |
| `roles/common/` | All servers: base packages, `ufw`, node-exporter, `*.atmos.lan` hosts entries, swap file outside the cluster |
| `roles/docker/` | `nexus-traefik`, `jenkins` |
| `roles/nexus/`, `roles/traefik/` | `nexus-traefik`: image registry, HTTPS entry point |
| `roles/jenkins/` | `jenkins`: CI server |
| `roles/k3s/` | `k8s-cp`, `k8s-w1`: k3s cluster, Traefik `HelmChartConfig`, access to the Nexus registry |
| `site.yml` | Configures all servers |

## Usage

Manual once: VirtualBox, Vagrant and the OpenSSH server on the host PC, with a clone of this repository there (only `git pull`, all changes on the Mac); Ansible on the Mac. `atmos-host` is the SSH alias of the PC.

```bash
ssh atmos-host "cd atmos-ansible && git pull && vagrant up"      # create and start the servers
ansible-playbook site.yml --ask-vault-pass --ask-become-pass      # configure all servers (from the Mac)
ssh atmos-host "cd atmos-ansible && vagrant halt k8s-w1 k8s-cp jenkins nexus-traefik"   # stop safely
```

Running `site.yml` again changes nothing on a correct server. `vagrant halt jenkins` stops only CI; the application keeps running.

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
