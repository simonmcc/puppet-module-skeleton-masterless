
# puppet-module-skeleton-masterless

puppet module that can be used to prepare an Ubuntu 12.04 host for the familytracker drupal application.


deploy/boostrap.sh will:

1. install the appropriate puppet labs apt repo
2. install puppet
3. determine if this is a vagrant or production install
    1. vagrant - install from /vagrant directory
    2. non-vagrant, i.e. production, use a ssh deploy key dropped into `/root/.ssh/.id_rsa_familytracker_deploykey` to pull down the familytracker module from the github private repo
4. install ruby gems package
5. install librarian-puppet as a ruby gem
5. seed /etc/puppet from the deploy directory
6. run librarian-puppet from /etc/puppet (which should include a Puppetfile)
7. run `puppet apply /etc/puppet/manifests/site.pp`

