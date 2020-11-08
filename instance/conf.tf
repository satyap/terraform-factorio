# Render settings file from template
data "template_file" "server-settings" {
  template = file("${path.module}/conf/server-settings-template.json")
  vars = {
    GAME_PASSWORD = var.game_password
  }
}

resource "local_file" "server-settings" {
  content  = data.template_file.server-settings.rendered
  filename = "${path.module}/build/conf/server-settings-template.json"
}

# Copy other files
resource "local_file" "conf_files" {
  content  = file("${path.module}/conf/${each.key}")
  filename = "${path.module}/build/conf/${each.key}"
  for_each = toset([
    "factorio-backup.service",
    "factorio-headless.service",
    "factorio-restore.service",
    "server-adminlist.json",
  ])
}

# Create ZIP
data "archive_file" "conf" {
  depends_on = [
    local_file.conf_files,
    local_file.server-settings,
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
