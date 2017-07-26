provider "aws" {
  region = "${var.region}"
}

# This is the root ssh key pair on your machine we will be using to access our cloud provisioned resources.
resource "aws_key_pair" "root" {
  key_name = "root-ssh-key-${var.region}"
  public_key = "${var.ssh_key}"
}

# A bucket for the s3 logs related to the actual terraform states bucket
resource "aws_s3_bucket" "terraform-logs" {
  bucket = "terraform-states-logs-${var.region}"
  acl = "log-delivery-write"

  tags {
    Name = "terraform-states-logs-${var.region}"
    ManagedBy = "Terraform"
  }
}

# The main terraform states backet
resource "aws_s3_bucket" "terraform-states" {
  bucket = "terraform-states-${var.region}"
  acl = "private"

  # This is good for just incase the file gets corrupted or something bad.
  versioning {
    enabled = true
  }

  # Send all S3 logs to another bucket
  logging {
    target_bucket = "${aws_s3_bucket.terraform-logs.id}"
    target_prefix = "logs/"
  }

  tags {
    Name = "terraform-states-${var.region}"
    ManagedBy = "Terraform"
  }
}
