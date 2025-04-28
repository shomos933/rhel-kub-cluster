output "master" {
  value = {
    name = libvirt_domain.master.name
    ip   = var.master.static_ip
  }
}

output "workers" {
  value = [
    for i in range(length(var.workers)) : {
      name = libvirt_domain.worker[i].name
      ip   = var.workers[i].static_ip
    }
  ]
}

