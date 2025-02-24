data "aws_region" "current" {}

resource "aws_vpc" "gitlab_vpc" {
    cidr_block = "10.0.0.0/16"
    tags = {
        Name = "gitlab-vpc"
    }
}

resource "aws_subnet" "public_subnet" {
    vpc_id = aws_vpc.gitlab_vpc.id
    cidr_block = "10.0.1.0/24"
    map_public_ip_on_launch = true
    tags = {
        Name = "gitlab-public-subnet"
    }
  
}

resource "aws_subnet" "private_subnet" {
    vpc_id = aws_vpc.gitlab_vpc.id
    cidr_block = "10.0.2.0/24"
    map_public_ip_on_launch = true
    tags = {
        Name = "gitlab-public-subnet"
    } 
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.gitlab_vpc.id
  tags = {
    Name = "gitlab-igw"
  }
}

resource "aws_route_table" "public_rt" {
 vpc_id = aws_vpc.gitlab_vpc.id
 route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
 }
 tags = {
    Name = "gitlab-public-rt"
 }
}

resource "aws_route_table_association" "publc_rt_assoc" {
    subnet_id = aws_subnet.public_subnet.id
    route_table_id = aws_route_table.public_rt.id
}

resource "aws_db_instane" "gitlab_db" {
    allocated_storage = 20
    engine = "postgres"
    engine_version = "12.5"
    instance_class = "db.t3.micro"
    name = "gitlabhq_production"
    username = var.db_username
    password = var.db_password
    parameter_group_name = "default.postgres12"
    skip_final_snapshot = true
    vpc_security_group_ids = [aws_security_group.gitlab_sg.id]
    db_subnet_group_name = aws_db_subnet_group.gitlab_db_subnet.id
    tags = {
        Name = "gitlab-rds"
    }
}

resource "aws_db_subnet_group" "gitlab_db_subnet" {
  name       = "gitlab-db-subnet"
  subnet_ids = [aws_subnet.private_subnet.id]
  tags = {
    Name = "gitlab-db-subnet"
  }
}

resource "aws_elasticache_subnet_group" "gitlab_redis_subnet" {
  name       = "gitlab-redis-subnet"
  subnet_ids = [aws_subnet.private_subnet.id]
}

resource "aws_elasticache_cluster" "gitlab_redis" {
  cluster_id           = "gitlab-redis"
  engine               = "redis"
  node_type            = "cache.t3.micro"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis6.x"
  subnet_group_name    = aws_elasticache_subnet_group.gitlab_redis_subnet.name
  security_group_ids   = [aws_security_group.gitlab_sg.id]
  tags = {
    Name = "gitlab-redis"
  }
}

resource "aws_instance" "gitlab_instance" {
  ami                         = "ami-0c55b159cbfafe1f0" # Amazon Linux 2 AMI
  instance_type               = var.instance_type
  key_name                    = var.key_name
  subnet_id                   = aws_subnet.gitlab_private_subnet.id
  ecurity_group_ids   =        [aws_security_group.gitlab_sg.id]
  tags = {
    Name = "gitlab"
  }
}