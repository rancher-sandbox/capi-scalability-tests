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

resource "aws_iam_policy" "prom_policy" {
  name = "${var.project_name}-prom-node-policy"
  path = "/"
  description = "A policy for use with the agents nodes running prometheus so they can remote write"
  policy = jsonencode({
    Version: "2012-10-17"
    Statement: [
        {
            Effect: "Allow",
            Action: [
                "aps:RemoteWrite"
            ],
            Resource: "*",
        }
    ]
  })
}

resource "aws_iam_role" "prom_role" {
  name = "${var.project_name}-prom-node-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_policy_attachment" "prom_policy_role" {
  name       = "${var.project_name}-prom-node-attachment"
  roles      = [aws_iam_role.prom_role.name]
  policy_arn = aws_iam_policy.prom_policy.arn
}

resource "aws_iam_instance_profile" "prom_profile" {
  name = "${var.project_name}-prom-node-profile"
  role = aws_iam_role.prom_role.name
}

