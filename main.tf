provider "aws" {
  region = "ap-northeast-2"
}

resource "aws_instance" "k8s_node" {
  ami           = "ami-03137ee2d0c5af1fe"
  instance_type = "t3.medium"

  # Existing SSH key pair
  key_name = "korea"

  # Existing subnet
  subnet_id = "subnet-018bc4e98b0ba98a1"

  # Assign a public IPv4 address
  associate_public_ip_address = true

  tags = {
    Name = "k8s-node"
  }
}

