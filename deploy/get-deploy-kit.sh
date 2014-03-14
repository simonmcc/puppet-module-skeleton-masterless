#!/bin/sh

. /etc/lsb-release

# determine if this is a vagrant/dev deploy or the real deal
if [ -d '/vagrant' ]
then
    # vagrant install, use the key from the repo
    SSH_KEY="/vagrant/.ssh/id_rsa_showhouse_deploykey"
else
    # non-vagrant install, keys should already be in place
    SSH_KEY="/root/.ssh/id_rsa_showhouse_deploykey"
fi
chmod 600 ${SSH_KEY}

GIT=/usr/bin/git
APT_GET=/usr/bin/apt-get
apt-get update 2>&1 >/dev/null

if [ ! -x $GIT ]; then
    apt-get -q -y install git-core
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

( cd && ssh_wrapper git clone git@github.com:simonmcc/puppet-showhouse.git deploy-kit)
