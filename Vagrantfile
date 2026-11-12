# Four VMs of the Atmos on-premise platform.
# Vagrant creates them on the host PC; Ansible configures everything inside (site.yml).

BOX         = "bento/ubuntu-24.04"
BOX_VERSION = "202510.26.0"

# Host PC adapter for the bridged network (VBoxManage list bridgedifs).
BRIDGE = "ASIX USB to Gigabit Ethernet Family Adapter"

# Public key of the Mac (admin machine). Ansible logs in with this key.
ADMIN_PUBLIC_KEY = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAz+drwdDbiESoXZssfmob3fEpiEsLdXGuTmo7fREeLO atmos-admin"

# The order of this list is the start order of `vagrant up`.
# Every VM needs at least 2 vCPUs: with one vCPU the box kernel hangs early in boot.
SERVERS = [
  { name: "nexus-traefik", ip: "192.168.0.53", cpus: 2, memory: 3072 },
  { name: "jenkins",       ip: "192.168.0.54", cpus: 2, memory: 2560 },
  { name: "k8s-cp",        ip: "192.168.0.51", cpus: 2, memory: 2560 },
  { name: "k8s-w1",        ip: "192.168.0.52", cpus: 2, memory: 3584 },
]

Vagrant.configure("2") do |config|
  config.vm.box              = BOX
  config.vm.box_version      = BOX_VERSION
  config.vm.box_check_update = false
  config.vm.synced_folder ".", "/vagrant", disabled: true

  SERVERS.each do |server|
    config.vm.define server[:name] do |node|
      node.vm.hostname = server[:name]
      node.vm.network "public_network", ip: server[:ip], bridge: BRIDGE

      node.vm.provider "virtualbox" do |vb|
        vb.name         = server[:name]
        vb.cpus         = server[:cpus]
        vb.memory       = server[:memory]
        vb.linked_clone = true
      end

      node.vm.provision "shell", name: "admin-key", inline: <<~SHELL
        KEY='#{ADMIN_PUBLIC_KEY}'
        grep -qxF "$KEY" /home/vagrant/.ssh/authorized_keys || echo "$KEY" >> /home/vagrant/.ssh/authorized_keys
      SHELL
    end
  end
end
