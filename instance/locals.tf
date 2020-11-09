locals {
  conf_files = toset([
    "factorio-backup.service",
    "factorio-headless.service",
    "factorio-restore.service",
    "install.bash",
    "server-adminlist.json",
    "server-settings.json",
  ])
}
