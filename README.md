# Headless Factorio server

Terraform modules to provision a headless Factorio server in AWS, with save game
backups to S3.

## Quick start

### Requirements

* [Terraform](https://www.terraform.io) version 0.12.x
* Amazon AWS account and [access keys](https://docs.aws.amazon.com/general/latest/gr/aws-sec-cred-types.html#access-keys-and-secret-access-keys)

### Initial setup

* Put AWS credentials in `~/.aws/credentials` (`aws_access_key_id` and
  `aws_secret_access_key`).

* Create the resources under `bootstrap`. These are a role and policy in order for the rest of terraform to work, and you can use this profile for all other actions with the factorio service.

* In ~/.aws/config, set up a profile `factorio`, which should be pointed at a role that uses the policy inside `bootstrap/`:

```
[profile factorio]
region = us-east-1
role_arn=arn:aws:iam::YOURACCOUNT_HERE:role/factorio-tf
source_profile=default
```

* Configure Factorio server (see [Setting up a Linux Factorio server](https://wiki.factorio.com/Multiplayer#Setting_up_a_Linux_Factorio_server)):

      vim conf/server-settings-template.json

* Configure infrastructure:

```
cd instance/
terraform init
terraform apply
terraform output
```
    
* Connect to the instance using AWS SSM

* Commands available:

```
sudo service factorio-restore
sudo service factorio-headless
sudo service factorio-backup
```

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
