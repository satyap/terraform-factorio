# Render config files from template
data "template_file" "conf_files" {
  for_each = local.conf_files
  template = file("${path.module}/conf/${each.key}")
  vars = {
    GAME_PASSWORD = var.game_password
    S3_BUCKET     = aws_s3_bucket.backup.id
  }
}

# Write templates to the files
resource "local_file" "conf_files" {
  for_each = local.conf_files
  content  = data.template_file.conf_files[each.key].rendered
  filename = "${path.module}/build/conf/${each.key}"
}

# Create ZIP
data "archive_file" "conf" {
  depends_on = [
    local_file.conf_files,
  ]
  output_path = "${path.module}/build/conf.zip"
  source_dir  = "${path.module}/build/conf"
  type        = "zip"
}

# Upload ZIP
resource "aws_s3_bucket_object" "conf" {
  bucket = aws_s3_bucket.backup.id
  etag   = data.archive_file.conf.output_md5
  key    = "conf/conf.zip"
  source = "${path.module}/build/conf.zip"
}
