resource "aws_iam_policy" "backup" {
  name = "factorio-iam-role-policy-backup"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "s3:*",
      "Effect": "Allow",
      "Resource": [
        "${aws_s3_bucket.backup.arn}",
        "${aws_s3_bucket.backup.arn}/saves/*"
      ]
    },
    {
      "Action": "s3:Get*",
      "Effect": "Allow",
      "Resource": [
        "${aws_s3_bucket.backup.arn}/conf/*"
      ]
    }
  ]
}
POLICY
}

resource "aws_iam_role" "backup" {
  name = "factorio-iam-role-backup"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
POLICY
}

data "aws_iam_policy" "managed" {
  arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "backup" {
  role       = aws_iam_role.backup.name
  policy_arn = aws_iam_policy.backup.arn
}

resource "aws_iam_role_policy_attachment" "managed" {
  role       = aws_iam_role.backup.name
  policy_arn = data.aws_iam_policy.managed.arn
}

resource "aws_iam_instance_profile" "backup" {
  name = "factorio-instance-profile"
  role = aws_iam_role.backup.name
}
