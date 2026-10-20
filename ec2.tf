locals {
  user_data_1 = <<-EOF
    #!/bin/bash
    dnf update -y
    dnf install -y nginx
    cat > /usr/share/nginx/html/index.html <<'HTML'
    <!DOCTYPE html>
    <html>
    <head><title>NLB Demo - Instance 1</title></head>
    <body style="font-family:Arial; background:#1a1a2e; color:#eee; text-align:center; padding:60px">
      <h1 style="color:#e94560">🚀 NLB + Nginx Demo</h1>
      <p>You are connected to: <strong>EC2 Instance 1 — AZ1</strong></p>
      <p style="color:#aaa">Traffic routed via AWS Network Load Balancer (Layer 4)</p>
    </body>
    </html>
    HTML
    systemctl enable nginx
    systemctl start nginx
  EOF

  user_data_2 = <<-EOF
    #!/bin/bash
    dnf update -y
    dnf install -y nginx
    cat > /usr/share/nginx/html/index.html <<'HTML'
    <!DOCTYPE html>
    <html>
    <head><title>NLB Demo - Instance 2</title></head>
    <body style="font-family:Arial; background:#1a1a2e; color:#eee; text-align:center; padding:60px">
      <h1 style="color:#0fd3a0">🚀 NLB + Nginx Demo</h1>
      <p>You are connected to: <strong>EC2 Instance 2 — AZ2</strong></p>
      <p style="color:#aaa">Traffic routed via AWS Network Load Balancer (Layer 4)</p>
    </body>
    </html>
    HTML
    systemctl enable nginx
    systemctl start nginx
  EOF
}

resource "aws_instance" "web_1" {
  ami                    = data.aws_ami.amazon_linux_2023.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public_1.id
  vpc_security_group_ids = [aws_security_group.ec2.id]
  key_name               = var.key_name != "" ? var.key_name : null
  user_data              = local.user_data_1

  tags = {
    Name    = "${var.project_name}-ec2-1"
    Project = var.project_name
    Role    = "webserver"
  }
}

resource "aws_instance" "web_2" {
  ami                    = data.aws_ami.amazon_linux_2023.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public_2.id
  vpc_security_group_ids = [aws_security_group.ec2.id]
  key_name               = var.key_name != "" ? var.key_name : null
  user_data              = local.user_data_2

  tags = {
    Name    = "${var.project_name}-ec2-2"
    Project = var.project_name
    Role    = "webserver"
  }
}