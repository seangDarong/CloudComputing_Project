resource "aws_db_subnet_group" "mysql" {
	name       = "${var.project_name}-db-subnet-group"
	subnet_ids = [aws_subnet.private_1.id, aws_subnet.private_2.id]

	tags = {
		Name = "${var.project_name}-db-subnet-group"
	}
}

resource "aws_db_instance" "mysql" {
	identifier = "${var.project_name}-mysql"

	engine               = "mysql"
	instance_class       = var.db_instance_class
	allocated_storage    = 20
	storage_type         = "gp3"
	db_name              = var.db_name
	username             = var.db_username
	password             = var.db_password
	port                 = 3306
	multi_az             = false
	publicly_accessible  = false
	storage_encrypted    = true
	skip_final_snapshot  = true
	deletion_protection   = false
	apply_immediately    = true
	backup_retention_period = 0

	db_subnet_group_name  = aws_db_subnet_group.mysql.name
	vpc_security_group_ids = [aws_security_group.db.id]

	tags = {
		Name = "${var.project_name}-mysql"
	}
}
