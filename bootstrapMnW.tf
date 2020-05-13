
resource "null_resource" "bash-masters" {
depends_on =[
  null_resource.ca-masters, 
  null_resource.kubcnf-masters,
  aws_lb.k8s-LB,
]
  count = var.Mcount


  connection {
    type         = "ssh"
    user         = var.user
    password     = var.password
    host         = "${aws_instance.k8s-MSTR[count.index].public_ip}"
    private_key  = "${file(var.sshkey)}"
   
  }


  provisioner "remote-exec" {
    inline = ["sudo apt update", "sudo apt install python -y"] #Ansible requires python
 }


// change scripts if master nodes != 3

  provisioner "local-exec" {              #ssh-add the private key on local machine first
          command = " ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u ubuntu -i '${aws_instance.k8s-MSTR[count.index].public_ip},' ansible/etcd.yaml"
  }

  provisioner "local-exec" {
     command = " ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u ubuntu -i '${aws_instance.k8s-MSTR[count.index].public_ip},' ansible/masters.yaml"
  }

 }
  

resource "null_resource" "bash-workers" {
depends_on =[
  null_resource.bash-masters,
]
  count = var.Wcount


  connection {
    type         = "ssh"
    user         = var.user
    password     = var.password
    host         = "${aws_instance.k8s-WRKR[count.index].public_ip}"
    private_key  = "${file(var.sshkey)}"
   
  }

provisioner "remote-exec" {
    inline = ["sudo apt update", "sudo apt install python -y"] 
  
}
  provisioner "local-exec" {
    command = " ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u ubuntu -i '${aws_instance.k8s-WRKR[count.index].public_ip},' ansible/workers.yaml"
  } 
     
}