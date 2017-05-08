# -*- mode: ruby -*-
# vi: set ft=ruby :
#
# Borrowed heavily from: https://github.com/rudolfb/vagrant-phoenix-postgres

$script = <<SCRIPT
date > /etc/vagrant_provisioned_at

echo "=== dependencies"

# https://bugs.launchpad.net/ubuntu/+bug/1561250
if [ $(cat /etc/hosts | grep -co 'ubuntu-xenial') = 0 ]; then
  echo "sudo sh -c ""echo '127.0.1.1 ubuntu-xenial' >> /etc/hosts"""
  sudo sh -c "echo '127.0.1.1 ubuntu-xenial' >> /etc/hosts"
else
  echo "Found entry 'ubuntu-xenial' in the /etc/hosts"
fi

# Install build dependencies for a sane build environment
sudo apt-get -y update
sudo apt-get -y install autoconf bison build-essential libssl-dev libyaml-dev libreadline6-dev zlib1g-dev libncurses5-dev libffi-dev libgdbm3 libgdbm-dev libgtk2.0-0 libgtk2.0-bin libgtk2.0-common inotify-tools

echo "=== git"

# Install Git if not available
if [ -z `which git` ]; then
  echo "===== Installing Git"
  sudo apt-get -y update
  sudo apt-get -y install git-core
fi

echo "=== nodejs"

if [ -z `which nodejs` ]; then
  # Instructions from:
  # https://nodesource.com/blog/nodejs-v012-iojs-and-the-nodesource-linux-repositories
  curl -sL https://deb.nodesource.com/setup_5.x | sudo -E bash -
  sudo apt-get install -y nodejs
fi

echo "=== postgres"

APP_DB_USER=postgres
APP_DB_PASS=$APP_DB_USER

PG_VERSION=9.5

export DEBIAN_FRONTEND=noninteractive

PG_REPO_APT_SOURCE=/etc/apt/sources.list.d/pgdg.list
if [ ! -f "$PG_REPO_APT_SOURCE" ]
then
  # Add PG apt repo:
  echo "deb http://apt.postgresql.org/pub/repos/apt/ xenial-pgdg main" > "$PG_REPO_APT_SOURCE"

  # Add PGDG repo key:
  wget --quiet -O - http://apt.postgresql.org/pub/repos/apt/ACCC4CF8.asc | sudo apt-key add -
fi

# Update package list and upgrade all packages
sudo apt-get update
sudo apt-get -y upgrade

sudo apt-get -y install "postgresql-$PG_VERSION" "postgresql-contrib-$PG_VERSION"
sudo apt-get -y install libpq-dev # For building ruby 'pg' gem

PG_CONF="/etc/postgresql/$PG_VERSION/main/postgresql.conf"
PG_HBA="/etc/postgresql/$PG_VERSION/main/pg_hba.conf"

# Edit postgresql.conf to change listen address to '*':
sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/" "$PG_CONF"

# trust everyone
cat > $PG_HBA <<EOF
local   all             all                                     trust
host    all             all             127.0.0.1/32            trust
host    all             all             ::1/128                 trust
EOF

# Restart so that all new config is loaded:
service postgresql restart

echo "=== elixir"

# Install elixir if not available
# Note: the URL of erlang will
if [ -z `which elixir` ]; then
  # https://www.erlang-solutions.com/resources/download.html
  wget https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb
  sudo dpkg -i erlang-solutions_1.0_all.deb
  sudo apt-get -y update
  apt-get -y install erlang erlang-manpages erlang-doc erlang-tools elixir
fi
SCRIPT

$script_unpriv =  <<SCRIPT
echo "=== phoenix"

# Install the latest version of Phoenix
  echo "===== Installing Phoenix"
  mix local.hex --force
  mix local.rebar --force
  mix archive.install "https://github.com/phoenixframework/archives/raw/master/phoenix_new-1.2.1.ez" --force

echo "=== Done"
SCRIPT

VAGRANTFILE_API_VERSION = '2'

MEMORY_SIZE_MB = 1024
NUMBER_OF_CPUS = 2
VM_NAME = "oscon17-elixir-phoenix"
VM_LINKED = true

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.provider "virtualbox" do |v|
    v.memory = MEMORY_SIZE_MB
    v.cpus = NUMBER_OF_CPUS
    v.name = VM_NAME
    v.linked_clone = VM_LINKED
  end

  config.vm.provision 'shell', inline: $script

  # Every Vagrant virtual environment requires a box to build off of.
  config.vm.box = 'ubuntu/xenial64'

  config.vm.provision :shell, inline: $script
  config.vm.provision :shell, inline: $script_unpriv, privileged: false

  # phoenix port forwarding
  config.vm.network :forwarded_port, host: 4000, guest: 4000

  # postgres port forwarding
  config.vm.network :forwarded_port, host: 5432, guest: 5432

end
