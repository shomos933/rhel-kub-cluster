variable "vm_image_path" {
  description = "Путь к образу Ubuntu 24.04 server cloud (qcow2)"
  type        = string
  default     = "/home/shom/OS_images/ubuntu-24.04-server-cloudimg-amd64.img"
}

variable "ssh_key" {
  description = "Path to SSH public key"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}


variable "network_name" {
  description = "Имя libvirt-сети для подключения интерфейсов"
  type        = string
  default     = "default"
}

variable "storage_pool" {
  description = "Имя libvirt-пула для хранения дисков"
  type        = string
  default     = "k8s_pool"
}

variable "master" {
  type = object({
    hostname  = string
    static_ip = string
    memory    = number
    vcpus     = number
    disk_size = number
  })
  default = {
    hostname  = "k8s-master"
    static_ip = "192.168.123.121"
    memory    = 3072
    vcpus     = 4
    disk_size = 30
  }
}

variable "workers" {
  type = list(object({
    hostname  = string
    static_ip = string
    memory    = number
    vcpus     = number
    disk_size = number
  }))
  default = [
    {
      hostname  = "k8s-worker-1"
      static_ip = "192.168.123.122"
      memory    = 5120
      vcpus     = 4
      disk_size = 35
    },
    {
      hostname  = "k8s-worker-2"
      static_ip = "192.168.123.123"
      memory    = 5120
      vcpus     = 4
      disk_size = 35
    }
  ]
}

