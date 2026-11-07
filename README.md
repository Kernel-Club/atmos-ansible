# project-atmos-onprem-ansible

Ansible for the on-premise platform of **Project Atmos**: creates the servers in VirtualBox and configures everything inside them.

```text
Admin machine (WSL2: Ansible)
 ├─ VBoxManage ─► creates the VMs
 └─ SSH ────────► tools   Docker, Nexus, Jenkins, Traefik
                  k8s-cp  k3s server
                  k8s-w1  k3s agent
```

## Contents

| Path | What it does |
|---|---|
| `inventory/` | Servers with fixed addresses, plus `localhost` for host tasks |
| `group_vars/` | VM resources, pinned versions, secrets in Ansible Vault |
| `roles/virtualbox_vm/` | Creates the VM, installs Ubuntu, network, `clean` snapshot |
| `roles/common/` | Base packages, `ufw`, node-exporter, `*.atmos.lan` hosts entries |
| `roles/docker/`, `nexus/`, `jenkins/`, `traefik/` | CI server `tools`: registry, Jenkins, HTTPS entry point |
| `roles/k3s/` | k3s cluster, Traefik `HelmChartConfig`, access to the Nexus registry |
| `vms.yml` · `site.yml` · `stop.yml` | Create and start · configure · stop safely |

## Usage

Prerequisite (the only manual step): VirtualBox, WSL2 and Ansible on the host computer.

```bash
ansible-playbook vms.yml  --ask-vault-pass   # create and start the servers
ansible-playbook site.yml --ask-vault-pass   # configure all servers
ansible-playbook stop.yml                    # stop: k8s-w1 → k8s-cp → tools
```

Running `site.yml` again changes nothing on a correct server.

## Rebuild

Restore the `clean` snapshots (or run `vms.yml`) and run `site.yml`. Then follow the manual steps in [architecture.md](https://github.com/Kernel-Club/project-atmos-dev/blob/develop/docs/on-premise/architecture.md) (section 2): Jenkins credentials and job, first build, Flux bootstrap, Kubernetes Secrets.

## Secrets

Platform passwords are stored only encrypted with Ansible Vault. The vault password, kubeconfig, keys and `.env` files are never committed (see `.gitignore`).

## Related

| Repository | Role |
|---|---|
| [project-atmos-dev](https://github.com/Kernel-Club/project-atmos-dev) | Application and on-premise docs (`docs/on-premise/`) |
| [project-atmos-onprem-jenkins](https://github.com/Kernel-Club/project-atmos-onprem-jenkins) | CI pipeline |
| [project-atmos-onprem-k3s](https://github.com/Kernel-Club/project-atmos-onprem-k3s) | Everything inside the cluster: Helm chart, Flux, monitoring |

Branching: `main` + `feature/*` / `fix/*` with a Pull Request ([branching model](https://github.com/Kernel-Club/project-atmos-dev/blob/develop/docs/on-premise/branching-model.md)).
