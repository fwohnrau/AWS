#https://medium.com/@paweldudzinski/creating-aws-ecs-cluster-of-ec2-instances-with-terraform-893c15d1116

resource "aws_security_group" "rds_cust_sg" {
    vpc_id      = var.vpc

    ingress {
        protocol        = "tcp"
        from_port       = var.rdsDbPort
        to_port         = var.rdsDbPort
        cidr_blocks     = ["0.0.0.0/0"]
        #security_groups = [aws_security_group.ecs_sg.id]
    }

    egress {
        from_port       = 0
        to_port         = 65535
        protocol        = "tcp"
        cidr_blocks     = ["0.0.0.0/0"]
    }
}

resource "aws_db_subnet_group" "db_subnet_group" {
    subnet_ids  = [var.subnet_private_1,var.subnet_private_2]
}

resource "aws_db_instance" "mysql" {
    identifier                = var.rdsDBType
    allocated_storage         = 5
    backup_retention_period   = 2
    #backup_window             = var.rdsBackupWindow
    #maintenance_window        = var.rdsMaintenanceWindow
    multi_az                  = false
    engine                    = "mysql"
    engine_version            = "5.7"
    instance_class            = var.rdsInstanceType
    name                      = var.rdsDbName
    username                  = var.rdsCustAdminUser
    password                  = var.rdsAdminPwd
    port                      = var.rdsDbPort
    db_subnet_group_name      = aws_db_subnet_group.db_subnet_group.id
    vpc_security_group_ids    = [aws_security_group.rds_cust_sg.id]
    skip_final_snapshot       = true
    final_snapshot_identifier = "${var.rdsDbName}-final"
    publicly_accessible       = false
}


