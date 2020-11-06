terraform {
  required_version = ">= 0.12"
}

provider "aws" {
  region  = var.region
  version = "~> 2.13"
}

variable "region" {
  type        = string
  default     = "us-east-1"
  description = "AWS region to create resources in."
}

resource "aws_iam_policy" "factorio" {
  name = "factorio-tf"

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "ec2:*",
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "aws:ResourceTag/Project": "factorio"
                }
            }
        },
        {
            "Sid": "VisualEditor2",
            "Effect": "Allow",
            "Action": [
                "iam:*",
                "s3:*"
            ],
            "Resource": [
                "arn:aws:iam::*:instance-profile/factorio-instance-profile",
                "arn:aws:iam::*:role/factorio-iam-role-backup",
                "arn:aws:iam::*:policy/factorio-iam-role-policy-backup",
                "arn:aws:s3:::factorio*"
            ]
        }
    ]
}
POLICY
}

resource "aws_iam_role" "factorio" {
  name = "factorio-tf"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "AWS": "arn:aws:iam::YOUR_ACCOUNT_HERE:user/YOUR_USER_HERE"
      },
      "Effect": "Allow",
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "factorio" {
  role       = aws_iam_role.factorio.name
  policy_arn = aws_iam_policy.factorio.arn
}
