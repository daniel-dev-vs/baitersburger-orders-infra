resource "aws_security_group" "alb_sg" {
  name        = "baitersburger-alb-sg"
  description = "Security group for ALB - allows HTTP/HTTPS traffic"
  vpc_id      = data.aws_vpc.aws_vpc_default.id

  ingress {
    description = "HTTP from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS from internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "baitersburger-alb-sg"
  })
}




resource "aws_lb_target_group" "alb_order_target_group" {
  name        = "baitersburger-alb-tg"
  port        = 8080
  protocol    = "HTTP"
  target_type = "ip"  
  vpc_id      = data.aws_vpc.aws_vpc_default.id

  health_check {
    path                = "/actuator/health"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200-399"
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = var.tags
}

resource "aws_lb" "alb" {
  name               = "baitersburger-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = data.aws_subnets.aws_subnets_default.ids

  tags = var.tags
}

resource "aws_lb_listener" "alb_listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80" 
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_order_target_group.arn
  }
}