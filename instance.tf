resource "aws_instance" "this" {
  count = var.instance_count

  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public_subnet.id
  vpc_security_group_ids      = [aws_security_group.k8s_nodes.id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.k8s.key_name

  root_block_device {
    delete_on_termination = true
    volume_size           = 10
    volume_type           = "gp3"
    encrypted             = true
  }

  tags = merge(local.common_tags, {
    Name = "k8s-node-${count.index == 0 ? "master" : "worker-${count.index}"}"
    Role = count.index == 0 ? "master" : "worker"
  })
}