# ============================================================================
# INTENTIONALLY VULNERABLE TERRAFORM CONFIGURATION
# Demonstrates IaC security anti-patterns caught by tools like Trivy, TFLint
# ============================================================================

terraform {
  required_version = ">= 0.12"
  
  # VULNERABILITY 1: State file with sensitive data not encrypted
  # Risk: Secrets exposed in state file, infrastructure compromise
  backend "s3" {
    bucket = "my-terraform-state"
    key    = "prod/terraform.tfstate"
    region = "us-east-1"
    # Missing: encrypt = true
    # Missing: dynamodb_table for state locking
  }
}

provider "aws" {
  region = "us-east-1"
}

# ============================================================================
# VULNERABILITY 2: RDS Database with Exposed Credentials (CWE-798)
# Risk: Database compromise, data breach, unauthorized access
# ============================================================================
resource "aws_db_instance" "vulnerable_db" {
  identifier     = "prod-database"
  engine         = "mysql"
  engine_version = "5.7"
  instance_class = "db.t2.micro"
  
  # VULNERABILITY: Hardcoded master password
  username = "admin"
  password = "SuperSecretPassword123!@#"  # EXPOSED SECRET
  
  allocated_storage    = 20
  max_allocated_storage = 100
  
  # VULNERABILITY: Backup exposure
  backup_retention_period = 0  # No backups
  backup_window           = null
  
  # VULNERABILITY: Not encrypted at rest (CWE-311)
  storage_encrypted = false
  
  # VULNERABILITY: Publicly accessible (CWE-732)
  publicly_accessible = true
  
  # VULNERABILITY: No database encryption
  kms_key_id = null
  
  # VULNERABILITY: Missing security group restrictions
  vpc_security_group_ids = [aws_security_group.open_database.id]
  
  # VULNERABILITY: No monitoring/logging (CWE-778)
  enabled_cloudwatch_logs_exports = []
  
  # VULNERABILITY: No deletion protection
  deletion_protection = false
  
  skip_final_snapshot = true
  
  tags = {
    Name        = "prod-database"
    Environment = "production"
  }
}

# ============================================================================
# VULNERABILITY 3: Over-Permissive Security Group (CWE-732)
# Risk: Unauthorized network access, brute force attacks
# ============================================================================
resource "aws_security_group" "open_database" {
  name        = "open-database-sg"
  description = "Database security group"
  vpc_id      = aws_vpc.main.id

  # VULNERABILITY: Allow all inbound traffic
  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # ENTIRE INTERNET
  }

  # VULNERABILITY: Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]  # ENTIRE INTERNET
  }

  tags = {
    Name = "open-database-sg"
  }
}

# ============================================================================
# VULNERABILITY 4: S3 Bucket with Overly Permissive Access (CWE-732)
# Risk: Data breach, unauthorized modifications, ransomware
# ============================================================================
resource "aws_s3_bucket" "vulnerable_bucket" {
  bucket = "my-vulnerable-bucket-12345"

  tags = {
    Name        = "vulnerable-bucket"
    Environment = "production"
  }
}

# VULNERABILITY: Public read access on bucket
resource "aws_s3_bucket_acl" "vulnerable_bucket_acl" {
  bucket = aws_s3_bucket.vulnerable_bucket.id
  acl    = "public-read"  # EXPOSED DATA
}

# VULNERABILITY: No server-side encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "example" {
  bucket = aws_s3_bucket.vulnerable_bucket.id
  # MISSING: SSE configuration means data at rest unencrypted
}

# VULNERABILITY: No versioning
resource "aws_s3_bucket_versioning" "vulnerable_bucket_versioning" {
  bucket = aws_s3_bucket.vulnerable_bucket.id
  
  versioning_configuration {
    status = "Disabled"  # No version history for rollback/forensics
  }
}

# VULNERABILITY: No logging
resource "aws_s3_bucket_logging" "vulnerable_bucket_logging" {
  bucket = aws_s3_bucket.vulnerable_bucket.id
  # MISSING: Logging configuration
}

# VULNERABILITY: Public block disabled
resource "aws_s3_bucket_public_access_block" "vulnerable_bucket_block" {
  bucket = aws_s3_bucket.vulnerable_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# ============================================================================
# VULNERABILITY 5: Overly Permissive IAM Role (CWE-284)
# Risk: Privilege escalation, credential misuse, lateral movement
# ============================================================================
resource "aws_iam_role" "vulnerable_role" {
  name = "vulnerable-app-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# VULNERABILITY: Administrator access (CWE-284)
resource "aws_iam_role_policy_attachment" "admin_access" {
  role       = aws_iam_role.vulnerable_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"  # FULL AWS ACCESS
}

# ============================================================================
# VULNERABILITY 6: EC2 Instance Without Security Hardening
# Risk: Unauthorized access, malware installation, data exfiltration
# ============================================================================
resource "aws_instance" "vulnerable_instance" {
  ami           = "ami-0c55b159cbfafe1f0"  # Unpatched AMI
  instance_type = "t2.micro"

  # VULNERABILITY: Security group with open SSH
  security_groups = [aws_security_group.vulnerable_sg.name]

  # VULNERABILITY: No IAM instance profile for credential management
  # iam_instance_profile missing

  # VULNERABILITY: Detailed monitoring disabled
  monitoring = false

  # VULNERABILITY: No EBS encryption
  root_block_device {
    volume_type           = "gp2"
    volume_size           = 20
    delete_on_termination = true
    encrypted             = false  # NO ENCRYPTION
  }

  # VULNERABILITY: User data with secrets
  user_data = base64encode(<<-EOF
              #!/bin/bash
              export DB_PASSWORD="SuperSecretPassword123!@#"
              export API_KEY="sk-prod-1a2b3c4d5e6f7g8h9i0j"
              apt-get update
              apt-get install -y nodejs npm
              EOF
  )

  tags = {
    Name = "vulnerable-instance"
  }
}

# VULNERABILITY: Overly permissive security group for instances
resource "aws_security_group" "vulnerable_sg" {
  name = "vulnerable-instance-sg"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # SSH open to world
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ============================================================================
# VULNERABILITY 7: VPC without proper network segmentation
# Risk: Lateral movement, network-based attacks
# ============================================================================
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  # VULNERABILITY: DNS not hardened
  enable_dns_hostnames = false
  enable_dns_support   = false
}

# ============================================================================
# VULNERABILITY 8: KMS Key without proper access controls
# Risk: Unauthorized encryption/decryption, key exposure
# ============================================================================
resource "aws_kms_key" "vulnerable_key" {
  description             = "KMS key for encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = false  # No key rotation

  # VULNERABILITY: Overly permissive key policy
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM Root"
        Effect = "Allow"
        Principal = {
          AWS = "*"  # WORLD ACCESSIBLE
        }
        Action   = "kms:*"
        Resource = "*"
      }
    ]
  })

  tags = {
    Name = "vulnerable-key"
  }
}

# ============================================================================
# OUTPUTS with Sensitive Data (CWE-798)
# Risk: Secrets logged in terraform output/state
# ============================================================================
output "database_endpoint" {
  value = aws_db_instance.vulnerable_db.endpoint
}

output "database_password" {
  value     = aws_db_instance.vulnerable_db.password
  sensitive = false  # PASSWORD NOT MARKED SENSITIVE
}

output "bucket_name" {
  value = aws_s3_bucket.vulnerable_bucket.bucket
}
