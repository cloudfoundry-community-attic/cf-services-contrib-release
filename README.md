## Cloud Foundry Contrib

This repository contains legacy components which are not under active development. We can cannot vouch for their functionality. Feel free to use them as-is or enhance them as you need.

## OSS Contributions

The Cloud Foundry team uses GitHub and accepts contributions via [pull request](https://help.github.com/articles/using-pull-requests)

Follow these steps to make a contribution to any of our open source repositories:

1. Complete our CLA Agreement for [individuals](http://www.cloudfoundry.org/individualcontribution.pdf) or [corporations](http://www.cloudfoundry.org/corpcontribution.pdf)
1. Set your name and email

		git config --global user.name "Firstname Lastname"
		git config --global user.email "your_email@youremail.com"

1. Fork the repo

1. Make your changes on a topic branch, commit, and push to github and open a pull request.

Your pull request is much more likely to be accepted if:

- It is small and focused with a clear commit message that conveys the intent behind your change.

- The tests pass in CI (we use Travis CI for many of our components in large part because of their excellent support for pull requests).

- Your pull request includes tests.

We review pull requests regularly.

## Documentation

Our documentation, currently a work in progress, is available here: http://docs.cloudfoundry.com/

## Repository Contents

This repository is structures for use with BOSH, an open source tool for release engineering, deployment and lifecycle management of large scale distributed services. The directories are:

- **.final_builds**
- **config**: pointers to dependencies cached in the BOSH blobstore.
- **git**
- **jobs**: start and stop commands for each of the jobs (processes) running on Cloud Foundry nodes.
- **packages**: packaging instructions used by BOSH to build each of the dependencies.
- **releases**: yml files containing the git commit shas for each package in a given release.
- **src**: the source code for the components in Cloud Foundry. Note that each of the components is a submodule with a pointer to a specific sha. So even if you do not use BOSH to deploy Cloud Foundry, the list of submodule pointers

See the [documentation for deploying Cloud Foundry](http://docs.cloudfoundry.com/docs/running/deploying-cf/) for more information about using BOSH.

In order to deploy Cloud Foundry with BOSH, you will need to create a manifest. You can find a [sample manifest in the documentation](http://cloudfoundry.github.com/docs/running/deploying-cf/vsphere/cloud-foundry-example-manifest.html).

## Ask Questions

Questions about the Cloud Foundry Open Source Project can be directed to our Google Groups.

* BOSH Developers: [https://groups.google.com/a/cloudfoundry.org/group/bosh-dev/topics](https://groups.google.com/a/cloudfoundry.org/group/bosh-dev/topics)
* BOSH Users:[https://groups.google.com/a/cloudfoundry.org/group/bosh-users/topics](https://groups.google.com/a/cloudfoundry.org/group/bosh-users/topics)
* VCAP (Cloud Foundry) Developers: [https://groups.google.com/a/cloudfoundry.org/group/vcap-dev/topics](https://groups.google.com/a/cloudfoundry.org/group/vcap-dev/topics)

## File a bug

Bugs can be filed using Github Issues within the various repositories of the [Cloud Foundry](http://github.com/cloudfoundry) components.

