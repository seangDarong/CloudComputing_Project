resource "aws_lb" "main" {
    name = "project-alb"
    internal = false
    load_balancer_type = "application"
    security_groups = [aws_security_group.alb.id]
    subnets = [aws_subnet.public_1.id, aws_subnet.public_2.id]

    tags = {Name = "project-alb"}
}

resource "aws_lb_target_group" "web" {
    name = "project-tg"
    port = 3000
    protocol = "HTTP"
    vpc_id = aws_vpc.main.id

    health_check {
      path = "/"
      unhealthy_threshold = 2
      healthy_threshold = 2
      interval = 30
    }
}

resource "aws_lb_listener" "http" {
    load_balancer_arn = aws_lb.main.arn
    port = 80
    protocol = "HTTP"

    default_action {
      type = "forward"
      target_group_arn = aws_lb_target_group.app.arn
    }
}