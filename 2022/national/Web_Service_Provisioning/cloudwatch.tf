resource "aws_cloudwatch_dashboard" "worker" {
  dashboard_name = "worker"
  dashboard_body = jsonencode({
    widgets = [
      {
        height = 6
        width  = 6
        y      = 0
        x      = 0
        type   = "metric"
        properties = {
          metrics = [
            ["AWS/EC2", "CPUUtilization", "AutoScalingGroupName", aws_eks_node_group.app.resources[0].autoscaling_groups[0].name, { "region" : "ap-northeast-2" }]
          ]
          view    = "timeSeries"
          stacked = false
          region  = "ap-northeast-2"
          title   = "WORKER CPU"
          period  = 60
          stat    = "Average"
        }
      },
      {
        height = 6
        width  = 6
        y      = 0
        x      = 6
        type   = "metric"
        properties = {
          metrics = [
            ["AWS/EC2", "NetworkIn", "AutoScalingGroupName", aws_eks_node_group.app.resources[0].autoscaling_groups[0].name, { "region" : "ap-northeast-2" }],
            [".", "NetworkOut", ".", ".", { "region" : "ap-northeast-2" }]
          ]
          view    = "timeSeries"
          stacked = false
          title   = "WORKER NETWORK"
          region  = "ap-northeast-2"
          period  = 60
          stat    = "Average"
        }
      }
    ]
  })
}

/*
resource "aws_cloudwatch_dashboard" "stress" {
  dashboard_name = "stress"
  dashboard_body = jsonencode({
    widgets = [
      {
        height = 6
        width  = 6
        y      = 0
        x      = 0
        type   = "metric"
        properties = {
          metrics = [
            ["AWS/ApplicationELB", "RequestCount", "LoadBalancer", "app/stress-alb/b63fe88d09856c20"]
          ]
          view    = "timeSeries"
          stacked = false
          title   = "STRESS REQ COUNT"
          region  = "ap-northeast-2"
          stat    = "Sum"
          period  = 60
        }
      },
      {
        height = 6
        width  = 6
        y      = 0
        x      = 6
        type   = "metric"
        properties = {
          metrics = [
            ["AWS/ApplicationELB", "TargetResponseTime", "LoadBalancer", "app/stress-alb/b63fe88d09856c20"]
          ]
          view    = "timeSeries"
          stacked = false
          title   = "STRESS RES TIME"
          region  = "ap-northeast-2"
          stat    = "Average"
          period  = 60
        }
      },
      {
        height = 6
        width  = 6
        y      = 0
        x      = 12
        type   = "metric"
        properties = {
          metrics = [
            ["AWS/ApplicationELB", "HTTPCode_ELB_5XX_Count", "LoadBalancer", "app/stress-alb/b63fe88d09856c20", { "region" : "ap-northeast-2" }]
          ]
          view    = "timeSeries"
          stacked = false
          region  = "ap-northeast-2"
          period  = 60
          title   = "STRESS 5xx"
          stat    = "Sum"
        }
      }
    ]
  })
}
*/