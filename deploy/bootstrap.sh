#!/bin/sh

. /etc/lsb-release

PUPPET_INSTALLED=`dpkg -l | grep "^ii  puppet"`
if [ -z "${PUPPET_INSTALLED}" ]; then
    (cd /tmp ; wget http://apt.puppetlabs.com/puppetlabs-release-${DISTRIB_CODENAME}.deb; dpkg -i puppetlabs-release-${DISTRIB_CODENAME}.deb)
    apt-get update
    apt-get install --yes puppet
    touch /etc/puppet/hiera.yaml
fi

# Directory in which librarian-puppet should manage its modules directory
PUPPET_DIR='/etc/puppet'

# determine if this is a vagrant/dev deploy or the real deal
if [ -d '/vagrant' ]
then
    # vagrant install, use the key from the repo
    SSH_KEY="/vagrant/.ssh/.id_rsa_familytracker_deploykey"
else
    # non-vagrant install, keys should already be in place
    SSH_KEY="/root/.ssh/.id_rsa_familytracker_deploykey"
fi
chmod 600 ${SSH_KEY}

# NB: librarian-puppet might need git installed. If it is not already installed
# in your basebox, this will manually install it at this point using apt or yum
GIT=/usr/bin/git
APT_GET=/usr/bin/apt-get
YUM=/usr/sbin/yum
if [ ! -x $GIT ]; then
    if [ -x $YUM ]; then
        yum -q -y install git-core
    elif [ -x $APT_GET ]; then
        apt-get -q -y install git-core
    else
        echo "No package installer available. You may need to install git manually."
    fi
fi

# load the deploy key so we have github access for private repo
ssh_wrapper()
{
  # pre accept the GitHub SSH key
  ssh -oStrictHostKeyChecking=no github.com uname
  # wrap the command in an agent so that we don't pause for ssh auth
  # only works with phraseless keys
  SSH_CMD="ssh-add ${SSH_KEY} ; $*"
  echo "${SSH_CMD}" | ssh-agent bash -
}

# drop the config in place, but first find it
if [ -d '/vagrant/deploy' ]
then
  PUPPET_SRC=/vagrant/deploy
else
  PUPPET_SRC=$( cd `dirname $0` ; echo $PWD)
fi
echo PUPPET_SRC=$PUPPET_SRC
rsync -av ${PUPPET_SRC}/ /etc/puppet

# update the deployed Puppetfile
sed -i "s!/vagrant!${PUPPET_SRC}/..!" /etc/puppet/Puppetfile

if [ -z "`which gem`" ]; then
  sudo apt-get install --yes rubygems
fi

if [ `gem query --local | grep librarian-puppet | wc -l` -eq 0 ]; then
  gem install librarian-puppet
  ( cd $PUPPET_DIR && ssh_wrapper librarian-puppet install --clean --verbose )
else
  ( cd $PUPPET_DIR && ssh_wrapper librarian-puppet update --verbose )
fi

puppet apply --debug -vv --modulepath=$PUPPET_DIR/modules/ $PUPPET_DIR/manifests/site.pp
