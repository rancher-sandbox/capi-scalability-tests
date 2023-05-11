// AMI lookups

# data "aws_ami" "sles15sp4" {
#   most_recent = true
#   name_regex  = "^suse-sles-15-sp4-byos-v"
#   owners      = ["013907871322"]

#   filter {
#     name   = "architecture"
#     values = ["arm64"]
#   }

#   filter {
#     name   = "virtualization-type"
#     values = ["hvm"]
#   }

#   filter {
#     name   = "root-device-type"
#     values = ["ebs"]
#   }
# }


data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical


  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name  = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

resource "aws_key_pair" "key_pair" {
  key_name   = "${var.project_name}-key-pair"
  public_key = file(var.ssh_public_key_path)

  tags = {
    Project = var.project_name
    Name    = "${var.project_name}-ssh-key-pair"
  }
}

output "key_name" {
  value = aws_key_pair.key_pair.key_name
}

# output "latest_sles_ami" {
#   value = data.aws_ami.sles15sp4
# }

output "latest_ubuntu_ami" {
  value = data.aws_ami.ubuntu
}