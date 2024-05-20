resource "aws_ecs_cluster" "ecs" {
  name = "wordpress-cluster"
}

resource "aws_ecs_service" "ecs" {
  name            = "wordpress-service"
  cluster         = aws_ecs_cluster.ecs.id
  desired_count   = 1
  task_definition = aws_ecs_task_definition.ecs.family
}

resource "aws_ecs_task_definition" "ecs" {
  family                = "wordpress"
  container_definitions = data.template_file.wordpress_task.rendered
  volume {
    name      = "efs-fargate"
    host_path = "/var/www/html/"
  }
}

data "template_file" "wordpress_task" {
  template = file("wordpress_task.json")
  vars = {
    db_name        = data.aws_ssm_parameter.db_name.value,
    username       = data.aws_ssm_parameter.username.value,
    password       = data.aws_ssm_parameter.password.value,
    repository_url = "wordpress",
    db_host        = var.db_fqdn
  }
}

data "aws_ssm_parameter" "db_name" {
  name = local.db_name_local_can ? "db_name" : null
}

data "aws_ssm_parameter" "username" {
  name = local.username_local_can ? "username" : null
}

data "aws_ssm_parameter" "password" {
  name = local.password_local_can ? "password" : null
}