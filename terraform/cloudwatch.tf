resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name = "${var.project_name}-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods = 2
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"
  period = 120
  statistic = "Average"
  threshold = 70
  alarm_description = "Scale up when CPU > 70% for 4 minutes"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.web.name
  }

  alarm_actions = [aws_autoscaling_policy.scale_up.arn]
}

resource "aws_cloudwatch_metric_alarm" "low_cpu" {
  alarm_name = "${var.project_name}-low-cpu"
  comparison_operator = "LessThanThreshold"
  evaluation_periods = 2
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"
  period = 120
  statistic = "Average"
  threshold = 20
  alarm_description = "Scale down when CPU < 20% for 4 minutes"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.web.name
  }

  alarm_actions = [aws_autoscaling_policy.scale_down.arn]
}

resource "aws_cloudwatch_metric_alarm" "alb_errors" {
  alarm_name = "${var.project_name}-alb-5xx"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods = 1 
  metric_name = "HTTPCode_Target_5XX_Count"
  namespace = "AWS/ApplicationELB"
  period = 60
  statistic = "Sum"
  threshold = 10
  alarm_description = "Too many 5XX errors from the app"

  dimensions = {
    LoadBalancer = aws_lb.main.arn_suffix
  }
}

resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${var.project_name}-dashboard"
  dashboard_body = jsonencode({
    widgets = [
        {
            type = "metric"
            x = 0 
            y = 0 
            width = 12 
            height = 6
            properties = {
                title = "EC2 CPU Utilization"
                metrics = [["AWS/EC2", "CPUUtilization", "AutoScalingGroupName", aws_autoscaling_group.web.name]]
                period = 300
                stat = "Average"
                view = "timeSeries"
            }
        },
        {
            type = "metric"
            x = 12 
            y = 0 
            width = 12 
            height = 6
            properties = {
                title = "ALB Request Count"
                metrics = [["AWS/ApplicationELB", "RequestCount", "LoadBalancer", aws_lb.main.arn_suffix]]
                period = 300
                stat = "Sum"
                view = "timeSeries"
            }
        },
        {
            type = "metric"
            x = 0 
            y = 6 
            width = 12 
            height = 6
            properties = {
                title = "ASG Instance Count"
                metrics = [["AWS/AutoScaling", "GroupInServiceInstances", "AutoScalingGroupName", aws_autoscaling_group.web.name]]
                period = 300
                stat = "Average"
                view = "timeSeries"
            }
        }
    ]
  })
}