# IAM role and instance profile for SSM
resource "aws_iam_role" "clickhouse_role" {
  name = "clickhouse-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_policy" {
  role       = aws_iam_role.clickhouse_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "clickhouse_cluster_profile" {
  name = "clickhouse-cluster-profile"
  role = aws_iam_role.clickhouse_role.name
}

resource "aws_iam_instance_profile" "clickhouse_keeper_profile" {
  name = "clickhouse-keeper-profile"
  role = aws_iam_role.clickhouse_role.name
}

// Allow profile access to s3 bucket
resource "aws_iam_policy" "s3_policy" {
  name        = "s3-policy"
  description = "Allow access to S3 bucket"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["s3:*"]
      Resource = [aws_s3_bucket.configuration.arn, "${aws_s3_bucket.configuration.arn}/*"]
    }]
  })
}

// Attach the policy to the instance profile
resource "aws_iam_policy_attachment" "s3_policy_attachment" {
  name       = "s3-policy-attachment"
  policy_arn = aws_iam_policy.s3_policy.arn
  roles      = [aws_iam_instance_profile.clickhouse_cluster_profile.role, aws_iam_instance_profile.clickhouse_keeper_profile.role]
}

#CloudWatch
resource "aws_iam_role_policy_attachment" "cw_policy_attachment" {
  role       = aws_iam_role.clickhouse_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}



