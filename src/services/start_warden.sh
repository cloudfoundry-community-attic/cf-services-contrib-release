#! /bin/bash 

export rvmsudo_secure_path=1

START_DIR=`pwd`
(
  git clone --recursive --depth=100 --quiet --branch=master git://github.com/cloudfoundry/warden.git warden
  cd warden

  # Ignore this project BUNDLE_GEMFILE
  unset BUNDLE_GEMFILE

  # Close stdin
  exec 0>&-

  # Remove remnants of apparmor (specific to Travis VM)
  sudo dpkg --purge apparmor

  # Install dependencies
  sudo apt-get -y install debootstrap quota

  cd warden
  # rvmsudo bundle exec rake setup:bin[config/linux.yml]
  # Get waren rootfs
  # $START_DIR/download_binaries_from_s3.rb warden_rootfs.tar.gz
  # sudo mkdir -p /tmp/warden/rootfs
  # sudo tar zxf warden_rootfs.tar.gz -C /tmp/warden/rootfs

  bundle install
  rvmsudo bundle exec rake setup[config/linux.yml]
  rvmsudo bundle exec rake --trace warden:start[config/linux.yml] >>/tmp/warden.stdout.log 2>>/tmp/warden.stderr.log &
)
cd $START_DIR

uname -a

# Wait for warden to come up
sleeps=5
while [ ! -e /tmp/warden.sock ] && [ $sleeps -gt 0 ]
do
  echo 'Waiting for warden to start. Rechecking in 1 second'
  echo "Warden log contents"
  tail -n 200 '/tmp/warden.stderr.log'
  echo 'STDOUT'
  tail -n 200 '/tmp/warden.stdout.log'
  echo 'WARDEN LOG'
  tail -n 200 '/tmp/warden.log'
  echo "*****************************"
  let sleeps--
  sleep 1
done

if [ $sleeps -eq 0 ]
then
  echo 'Warden failed to start, failing the build'
  exit 1
if

echo "/tmp/warden.sock exists, let's run the specs"

