Cloud Foundry Services Contrib Release

--------------------------------------

#### Please note that support for v1 service brokers on which the following services relies upon has been removed as of cf-release [v228](https://github.com/cloudfoundry/cf-release/releases/tag/v228) . General instructions for migrating service brokers can be found [here](https://docs.google.com/document/d/1Pl1o7mxtn3Iayq2STcMArT1cJsKkvi4Ey1-d3TB_Nhs/edit?usp=sharing).

This repository contains a wide set of interesting services that can be added into your own Cloud Foundry.

You can find the following services in this repository (in alphabetical order):

-	elastic search
-	memcached
-	mongodbc
-	postgresql
-	rabbitmq (see [doc](docs/rabbitmq.md))
-	redis
-	vblob
-	swift

Each of these services are offered in a similar way - a single database or running instance running on a single machine.

When choosing data services for your applications you should always consult a data professional. Data is important. Please care about your data.

**Perhaps it is best to consider these services as "developer-only" services that can be provisioned and used quickly by developers.** That is, until you are read to understand how to do backup/restore of any given service instance and/or all of the service instances provisioned by all users.

You can deploy one or more of these services. If you don't run them, then your developers won't use them, and you won't have to support them. ZING!

Requirements
------------

It is assumed that you already have bosh running with a Cloud Foundry deployment.

You will need Ruby 1.9.3+ locally and the `bosh_cli` installed:

```
$ gem install bosh_cli
```

Usage
-----

To use this BOSH release, first upload it to your bosh:

```
bosh upload release https://bosh.io/d/github.com/cloudfoundry-community/cf-services-contrib-release?v=6
```

To deploy it you will need the source repository that contains templates:

```
git clone https://github.com/cloudfoundry-community/cf-services-contrib-release.git
cd cf-services-contrib-release
git checkout v6
```

### Bosh-lite

For [bosh-lite](https://github.com/cloudfoundry/bosh-lite), you can quickly create a deployment manifest:

```
templates/make_manifest warden
bosh -n deploy
```

**NOTE:** *The currently supported BOSH Lite stemcell for cf-services-contrib-release is version 388 which can be found [here](https://s3.amazonaws.com/bosh-jenkins-artifacts/bosh-stemcell/warden/bosh-stemcell-388-warden-boshlite-ubuntu-trusty-go_agent.tgz).*

### Openstack with Neutron

For openstack you will need to provide a stub file with your network details. You can use `examples/openstack-neutron-stub.yml` as a starting point.

```
templates/make_manifest openstack-neutron [path to your stub file]
bosh -n deploy
```

### Other

Create a deployment file to describe the services you want to activate and support. Say, call it `cf-services-contrib.yml`.

See the [examples/dns-all.yml](https://github.com/cloudfoundry/cf-services-contrib-release/blob/master/examples/dns-all.yml) for an example deployment file that runs all the services listed above.

Then target the deployment file and deploy it:

```
$ bosh deployment cf-services-contrib.yml
$ bosh deploy
```

This will then compile all the source packages, provision the virtual machines, and run all your services.

Authorize Services
------------------

Finally, you need to authorize each service gateway with your Cloud Foundry. For example, to authorize postgresql using the example deployment file:

```
$ cf create-service-auth-token <label> core <token>
```

-	**label**: the name of the package
-	**token**: the token you provided in your deployment file

For example:

```
$ cf create-service-auth-token mongodb core mytoken
```

You and all your users can now provision and bind the services:

```
$ cf create-service mongodb default my-mongodb
Creating service my-mongodb in org <org> / space <space> as <user>...
OK
```

If you're using bosh-lite, and have used the warden deployment manifest, you can authorize your services by executing:
```
$ rake setup
```

Repository Contents
-------------------

This repository is structures for use with BOSH, an open source tool for release engineering, deployment and lifecycle management of large scale distributed services. The directories are for two purposes:

Source:

-	**jobs**: start and stop commands for each of the jobs (processes) running on Cloud Foundry nodes.
-	**packages**: packaging instructions used by BOSH to build each of the dependencies.
-	**src**: the source code for the components in Cloud Foundry. Note that each of the components is a submodule with a pointer to a specific sha. So even if you do not use BOSH to deploy Cloud Foundry, the list of submodule pointers

Releases:

-	**releases**: yml files containing the references to blobs for each package in a given release; these are solved within **.final_builds**
-	**.final_builds**: references into the public blostore for final jobs & packages (each referenced by one or more **releases**)
-	**config**: URLs and access credentials to the bosh blobstore for storing final releases
-	**git**: Local git hooks

See the [documentation on bosh](http://docs.cloudfoundry.com/docs/running/bosh/) for more information about using BOSH.

In order to deploy Cloud Foundry with BOSH, you will need to create a manifest. You can view a sample manifest [examples/dns-all.yml](https://github.com/cloudfoundry/cf-services-contrib-release/blob/master/examples/dns-all.yml).

Development
-----------

### Running integration specs

1.	Deploy Cloud Foundry on bosh-lite [instructions](https://github.com/cloudfoundry/bosh-lite#deploy-cloud-foundry)
2.	Deploy Contrib Services on bosh-lite [instructions](https://github.com/cloudfoundry-community/cf-services-contrib-release#bosh-lite)
3.	Install Service auth tokens by running: `bundle install && rake setup`
4.	run specs: `rspec spec`

### Creating a dev-release

If you want to use all changes in master you can create a bosh dev release:

```
git clone https://github.com/cloudfoundry-community/cf-services-contrib-release
cd cf-services-contrib-release
./update
bosh create release
bosh upload release
bosh deploy
```

### Source Code

The source code for these services can be found inside this repo in the [src/services](https://github.com/cloudfoundry/cf-services-contrib-release/tree/master/src/services) folder

OSS Contributions
-----------------

The Cloud Foundry team uses GitHub and accepts contributions via [pull request](https://help.github.com/articles/using-pull-requests)

Follow these steps to make a contribution to any of our open source repositories:

1.	Complete our CLA Agreement for [individuals](http://www.cloudfoundry.org/individualcontribution.pdf) or [corporations](http://www.cloudfoundry.org/corpcontribution.pdf)
2.	Set your name and email

```
git config --global user.name "Firstname Lastname"
git config --global user.email "your_email@youremail.com"
```

1.	Fork the repo
2.	Make your changes on a topic branch, commit, and push to github and open a pull request.

Your pull request is much more likely to be accepted if:

-	It is small and focused with a clear commit message that conveys the intent behind your change.
-	The tests pass in CI (we use Travis CI for many of our components in large part because of their excellent support for pull requests).
-	Your pull request includes tests.

We review pull requests regularly.

Documentation
-------------

Our documentation, currently a work in progress, is available here: http://docs.cloudfoundry.com/

Ask Questions
-------------

Questions about the Cloud Foundry Open Source Project can be directed to our Google Groups.

-	BOSH Developers: [https://groups.google.com/a/cloudfoundry.org/group/bosh-dev/topics](https://groups.google.com/a/cloudfoundry.org/group/bosh-dev/topics)
-	BOSH Users:[https://groups.google.com/a/cloudfoundry.org/group/bosh-users/topics](https://groups.google.com/a/cloudfoundry.org/group/bosh-users/topics)
-	VCAP (Cloud Foundry) Developers: [https://groups.google.com/a/cloudfoundry.org/group/vcap-dev/topics](https://groups.google.com/a/cloudfoundry.org/group/vcap-dev/topics)

File a bug
----------

Bugs can be filed using [Github Issues](https://github.com/cloudfoundry/cf-services-contrib-release/issues).
