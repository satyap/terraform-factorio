# Run from cloud-config to initialize the daemons and copy files.
set -e

# Create user
adduser --no-create-home --home /opt/factorio factorio
usermod --expiredate 1 --lock factorio

# Factorio settings
mkdir -p /etc/factorio
cp ./server-settings.json ./server-adminlist.json /etc/factorio
chmod 644 /etc/factorio/*
chown root.root /etc/factorio

# Factorio services
cp ./factorio*.service /etc/systemd/system/
chmod 644 /etc/systemd/system/factorio*.service
chown root.root /etc/systemd/system/factorio*.service

# Install downloaded factorio
tar -C /opt -x -f /opt/factorio.tar.gz
rm /opt/factorio.tar.gz
mkdir -p /opt/factorio/saves
chown factorio. -R /opt/factorio

# Restart services
systemctl daemon-reload
