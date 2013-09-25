### Running the terracotta service specs in the provided Vagrant VM

When contributing to terracotta service it's useful to run it as a standalone
component. This test configuration uses [Vagrant 1.1x][vagrant].

[vagrant]: http://docs.vagrantup.com/v2/installation/index.html

Follow these steps to set up the terracotta service to run locally on your computer:

```shell
# clone the repo
cd ~/workspace
git clone http://github.com/cloudfoundry/cf-services-contrib-release
cd cf-services-contrib-release
./update
cd src/services/terracotta
bundle

# check that your version of vagrant is 1.1 or greater
vagrant --version

# create your test VM
rake test_vm
```

Creating the test VM is likely to take a while.

Note that if the rake test_vm step fails and you see an error like
"undefined method `configure' for Vagrant" or
"found character that cannot start any token while scanning for the next token"
it means the version of Vagrant is too old.
Install Vagrant version 1.1 or higher.

```shell
# initialize the test VM
cd ~/workspace/cf-services-contrib-release
vagrant up

# shell into the VM
vagrant ssh

# start warden
cd /warden/warden
rvmsudo bundle exec rake warden:start[config/test_vm.yml] 2>&1 > /tmp/warden.log &

# insall gems
cd /vagrant
bundle

# run specs
rvmsudo rake test:spec
```
