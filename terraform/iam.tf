resource "aws_iam_role" "ec2_role" {
    name = "${var.project_name}-ec2-role"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
            Action = "sts:AssumeRole"
            Effect = "Allow"
            Principal = { Service = "ec2.amazonaws.com" }
        }]
    })

    tags = { Name = "${var.project_name}-ec2-role"}
}

resource "aws_iam_role_policy_attachment" "cloudwatch" {
  role = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

data "aws_iam_policy_document" "ec2_s3_access" {
  statement {
    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.photos.arn]
  }

  statement {
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
    ]
    resources = ["${aws_s3_bucket.photos.arn}/uploads/*"]
  }
}

resource "aws_iam_policy" "ec2_s3_access" {
  name   = "${var.project_name}-s3-access"
  policy = data.aws_iam_policy_document.ec2_s3_access.json
}

resource "aws_iam_role_policy_attachment" "s3" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.ec2_s3_access.arn
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.project_name}-ec2-profile"
  role = aws_iam_role.ec2_role.name
}