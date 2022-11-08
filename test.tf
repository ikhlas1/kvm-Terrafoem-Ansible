#Defining VM Volume
resource "libvirt_volume" "VmTf-qcow2" {
  name = "VmTf.qcow2"
  pool = "default" # List storage pools using virsh pool-list
  #source = "./focal-server-cloudimg-amd64.img" 
  source = "https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64.img" # wget the img in the folder to save time and bandwidth and better securtiy
  format = "qcow2"
}


data "template_file" "user_data" {
  template = file("./cloud_init.cfg")
}

data "template_file" "network_config" {
  template = file("./network_config.cfg")
}

resource "libvirt_cloudinit_disk" "commoninit" {
  name           = "commoninit.iso"
  user_data      = data.template_file.user_data.rendered
  network_config = data.template_file.network_config.rendered
  pool           = "default"
}


# Define KVM domain to create
resource "libvirt_domain" "VmTf" {
  name      = "VmTf"
  memory    = "2048"
  vcpu      = 2
  cloudinit = libvirt_cloudinit_disk.commoninit.id

  network_interface {
    network_name   = "default" # List networks with virsh net-list
    wait_for_lease = false
  }

  disk {
    volume_id = libvirt_volume.VmTf-qcow2.id
  }

  console {
    type        = "pty"
    target_type = "serial"
    target_port = "0"
  }

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }
}
