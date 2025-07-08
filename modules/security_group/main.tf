resource "aws_security_group" "sg_openvpn" { # openvpn 보안 그룹
    name   = "openvpn-sg-${var.stage}-${var.servicename}"
    vpc_id = var.vpc_id

    ingress { 
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = [ "0.0.0.0/0" ]
    }

    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = [ "0.0.0.0/0" ]
    }

    ingress {
      from_port = 1194
        to_port = 1194
        protocol = "tcp"
        cidr_blocks = [ "0.0.0.0/0" ]
    }

    ingress {
      from_port = 943
        to_port = 943
        protocol = "tcp"
        cidr_blocks = [ "0.0.0.0/0" ]
    }

    egress { 
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "sg_alb" { # alb 보안 그룹
  name   = "alb-sg-${var.stage}-${var.servicename}"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"] 
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "sg_ec2" { # ec2 보안 그룹
  name   = "ec2-sg-${var.stage}-${var.servicename}"
  vpc_id = var.vpc_id

  ingress {
    from_port       = var.ec2_port_spring
    to_port         = var.ec2_port_spring
    protocol        = "tcp"
    security_groups = [aws_security_group.sg_alb.id]
  }

  ingress {
    from_port       = var.ec2_port_fastapi
    to_port         = var.ec2_port_fastapi
    protocol        = "tcp"
    security_groups = [aws_security_group.sg_alb.id]
  }

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.sg_openvpn.id]
    description     = "Allow SSH (port 22) from OpenVPN clients"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "sg_db" {
  name   = "db-sg-${var.stage}-${var.servicename}"
  vpc_id = var.vpc_id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.sg_ec2.id]
    description     = "Allow MySQL access from APP instances"
  }

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = [aws_security_group.sg_openvpn.id]
    description = "Allow MySQL from VPN clients"
  }

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.sg_openvpn.id]
    description     = "Allow SSH (port 22) from OpenVPN clients"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}