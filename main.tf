#--------------------------------------------------------------#
# Terraform resource to create security group for EC2 instance
#--------------------------------------------------------------#
resource "aws_security_group" "ec2_sg" {
  name        = "ec2_sg"
  description = "Allow SSH"
  vpc_id      = "${data.aws_vpc.vpc_id.id}"  

  ingress {
    description      = "Allow SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ec2_sg"
  }
}
#--------------------------------------------------------------#
# Terraform resource to create security group for RDS instance
#--------------------------------------------------------------#
resource "aws_security_group" "rds_sg" {
  name        = "rds_sg"
  description = "Allow inbound traffic from ec2 instance"
  vpc_id      = "${data.aws_vpc.vpc_id.id}"   

  ingress {
    description      = "Allow inbound traffic from ec2 instance"
    from_port        = 3306
    to_port          = 3306
    protocol         = "tcp"
    security_groups   = ["${aws_security_group.ec2_sg.id}"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "rds_sg"
  }
}
#--------------------------------------------------------------#
#       Terraform resource to create RDS DB Subnet group
#--------------------------------------------------------------#
resource "aws_db_subnet_group" "mysql_subnet_group" {
  name       = "main"
  subnet_ids = ["subnet-035683752417ffde2", "subnet-0440faab2278d6172"]

  tags = {
    Name = "mysql_subnet_group"
  }
}
#--------------------------------------------------------------#
#       Terraform resource to create RDS instance
#--------------------------------------------------------------#
resource "aws_db_instance" "my_db_instance" {
  allocated_storage    = 20
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  identifier            = "movies-db"
  db_name               = "movies_db"
  username             = var.db_username
  password             = var.db_password
  multi_az             = true
  skip_final_snapshot  = true
  backup_retention_period = 1
  db_subnet_group_name = aws_db_subnet_group.mysql_subnet_group.id
  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  tags = {
    "Name" = "movies-db"
  }
}
#--------------------------------------------------------------#
#       Terraform resource to create EC2 instance
#--------------------------------------------------------------#

resource "aws_instance" "movies_ec2" {
  ami           = "ami-0d71ea30463e0ff8d"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  key_name = "my-kp"
  subnet_id = "subnet-0bf1a9f580ac23b4b"
  associate_public_ip_address = true

  tags = {
    Name = "movies_ec2"
  }
}
