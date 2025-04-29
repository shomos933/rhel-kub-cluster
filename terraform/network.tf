resource "libvirt_network" "k8s_net" {
  name      = "k8s-net"
  autostart = true
  mode      = "nat"

  # адрес сети
  addresses = ["192.168.123.0/24"]

}

