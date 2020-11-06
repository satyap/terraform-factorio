# Headless Factorio server

Terraform modules to provision a headless Factorio server in AWS, with save game
backups to S3.

## Quick start

### Requirements

* [Terraform](https://www.terraform.io) version 0.12.x
* Amazon AWS account and [access keys](https://docs.aws.amazon.com/general/latest/gr/aws-sec-cred-types.html#access-keys-and-secret-access-keys)

### Initial setup

* Put AWS credentials in `~/.aws/credentials` (`aws_access_key_id` and
  `aws_secret_access_key`)

* Create the resources under `bootstrap`. These are a role and policy in order for the rest of terraform to work.

* Configure infrastructure:

      cd instance/
      terraform init
    
* Configure Factorio server (see [Setting up a Linux Factorio server](https://wiki.factorio.com/Multiplayer#Setting_up_a_Linux_Factorio_server)):

      vim conf/server-settings.json

### Game server

Create infrastructure:

    cd instance/
    terraform apply
    terraform output
    
    # Public IP of the game server
    ip = 3.121.142.76

The game server is automatically started and the most recent save games from S3
are restored onto the instance.

Destroy infrastructure after use:

    cd instance/
    terraform destroy -target=aws_instance.factorio

This will automatically backup the save games to the specified S3 bucket.

### Services

Several systemd services are provisioned to the server instance:

* `factorio-headless.service`: Service to start/stop the headless game server.
* `factorio-restore.service`: One shot service that restores save games from S3.
* `factorio-backup.service`: One shot service that backs up save games to S3.

### Limitations

Currently there is no support for creating a fresh game, just for loading existing
save games. The headless Factorio server expects the `--create FILE` argument to
create a game. The workaround is to create a game locally, export the save game,
and use that.

This provisioning code populates `--start-server FILE` (to load a named save game) or
`-start-server-load-latest` (to load the latest save game), depending on whether
the `factorio_save_game` variable is set.
