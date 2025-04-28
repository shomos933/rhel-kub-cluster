terraform {
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = ">= 0.8.3"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.9.1"
    }
  }
}

provider "libvirt" {
  uri = "qemu:///system"
}


# Пул для дисков
resource "libvirt_pool" "k8s_pool" {
  name = var.storage_pool
  type = "dir"
  target { path = "/home/shom/virsh_HDD/${var.storage_pool}" }
}

# Шаблоны cloud-init
data "template_file" "master_ci" {
  template = file("${path.module}/cloud-init.tpl")
  vars = {
    hostname  = var.master.hostname
    static_ip = var.master.static_ip
    ssh_key   = file(pathexpand(var.ssh_key))
  }
}
data "template_file" "worker_ci" {
  count    = length(var.workers)
  template = file("${path.module}/cloud-init.tpl")
  vars = {
    hostname  = var.workers[count.index].hostname
    static_ip = var.workers[count.index].static_ip
    ssh_key   = file(pathexpand(var.ssh_key))
  }
}

# === MASTER ===
 
resource "libvirt_volume" "master_disk" {
   name   = "${var.master.hostname}.qcow2"
   pool   = libvirt_pool.k8s_pool.name
   source = var.vm_image_path
   format = "qcow2"
}

resource "null_resource" "resize_master_disk" {
  provisioner "local-exec" {
    command = "qemu-img resize /home/shom/virsh_HDD/${var.storage_pool}/${var.master.hostname}.qcow2 ${var.master.disk_size}G"
  }
  depends_on = [ libvirt_volume.master_disk ]
}

# Добавляем задержку, чтобы убедиться, что resize завершился и блокировка снята
resource "time_sleep" "wait_after_resize_master" {
  create_duration = "10s"
  depends_on = [null_resource.resize_master_disk]
}

resource "libvirt_cloudinit_disk" "master_iso" {
  name      = "${var.master.hostname}-cloudinit.iso"
  pool      = libvirt_pool.k8s_pool.name
  user_data = data.template_file.master_ci.rendered
}

resource "libvirt_domain" "master" {
  name   = var.master.hostname
  memory = var.master.memory
  vcpu   = var.master.vcpus

 network_interface {
   network_name = libvirt_network.k8s_net.name
   # можно либо явно прописать addresses = [ var.master.static_ip ], 
   # либо полагаться на DHCP-static-host, если вы его добавите:
   addresses = [ var.master.static_ip ]
 }

  disk {
    volume_id = libvirt_volume.master_disk.id
  }

  cloudinit = libvirt_cloudinit_disk.master_iso.id

	depends_on = [
	  null_resource.resize_worker_disk,
  	libvirt_cloudinit_disk.worker_iso
	]

  console {
    type        = "pty"
    target_port = "0"
  }
  graphics {
    type           = "vnc"
    listen_type    = "address"
    listen_address = "0.0.0.0"
  }
}

# === WORKERS ===

resource "libvirt_volume" "worker_disk" {
  count  = length(var.workers)
  name   = "${var.workers[count.index].hostname}.qcow2"
  pool   = libvirt_pool.k8s_pool.name
  source = var.vm_image_path
  format = "qcow2"
}

resource "null_resource" "resize_worker_disk" {
  count = length(var.workers)
  provisioner "local-exec" {
    command = "qemu-img resize /home/shom/virsh_HDD/${var.storage_pool}/${var.workers[count.index].hostname}.qcow2 ${var.workers[count.index].disk_size}G"
  }
  depends_on = [ libvirt_volume.worker_disk ]
}

# Добавляем задержку, чтобы убедиться, что resize завершился и блокировка снята
resource "time_sleep" "wait_after_resize_worker" {
  create_duration = "10s"
  depends_on = [null_resource.resize_worker_disk]
}

resource "libvirt_cloudinit_disk" "worker_iso" {
  count     = length(var.workers)
  name      = "${var.workers[count.index].hostname}-cloudinit.iso"
  pool      = libvirt_pool.k8s_pool.name
  user_data = data.template_file.worker_ci[count.index].rendered
}

resource "libvirt_domain" "worker" {
  count  = length(var.workers)
  name   = var.workers[count.index].hostname
  memory = var.workers[count.index].memory
  vcpu   = var.workers[count.index].vcpus

 network_interface {
   network_name = libvirt_network.k8s_net.name
   addresses    = [ var.workers[count.index].static_ip ]
 }

  disk {
    volume_id = libvirt_volume.worker_disk[count.index].id
  }

  cloudinit = libvirt_cloudinit_disk.worker_iso[count.index].id

	depends_on = [
  	null_resource.resize_worker_disk,
  	libvirt_cloudinit_disk.worker_iso
	]

  console {
    type        = "pty"
    target_port = "0"
  }
  graphics {
    type           = "vnc"
    listen_type    = "address"
    listen_address = "0.0.0.0"
  }
}

