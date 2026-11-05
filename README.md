# project-atmos-onprem-provision

Ansible configuration for the on-premise platform of Project Atmos.

## Purpose

Configures the three virtual machines from the admin machine over SSH:

| VM | Role |
|---|---|
| `tools` | Jenkins, Docker, Nexus, Traefik (reverse proxy) |
| `k8s-cp` | k3s server |
| `k8s-w1` | k3s agent |

The VMs are created by hand (Ubuntu Server 24.04 LTS). This repository only configures them.

## Planned content

- `inventory/` — hosts and groups
- `group_vars/` — pinned versions and settings; secrets encrypted with Ansible Vault
- `roles/` — `common` (`ufw`, node-exporter), `k3s`, `docker`, `nexus`, `jenkins`, `traefik`
- `site.yml` — configures all VMs
- `stop.yml` — stops the VMs in the right order

## Secrets

Secrets are stored only encrypted with Ansible Vault. The vault password file, kubeconfig, SSH keys and `.env` files are never committed (see `.gitignore`).

## Related repositories

- [project-atmos-dev](https://github.com/Kernel-Club/project-atmos-dev) — application and architecture docs (`docs/on-premise/`)
- [project-atmos-onprem-jenkins](https://github.com/Kernel-Club/project-atmos-onprem-jenkins) — CI pipeline
- [project-atmos-onprem-gitops](https://github.com/Kernel-Club/project-atmos-onprem-gitops) — Flux and the Helm chart

## Branching

`main` is the current platform configuration. Changes go through `feature/*` or `fix/*` branches and a Pull Request to `main`. See `docs/on-premise/branching-model.md` in `project-atmos-dev`.
