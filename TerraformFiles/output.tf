output "instance1_public_ip" {
  value = aws_instance.Example1.public_ip
}

output "instance1_public_dns" {
  value = aws_instance.Example1.public_dns
}

output "instance2_public_ip" {
  value = aws_instance.Example2.public_ip
}

output "instance2_public_dns" {
  value = aws_instance.Example2.public_dns
}