#!/usr/bin/env bash

cat <<EOF
metacon-installer
-----------------
This will perform the following actions, all of which can be pretty easily
undone if needed:

  * Try to install rvm if it's not already installed
  * Update rvm
  * Install ruby 1.9.2 (or 1.9.3) safely isolated (by rvm)
    from your system ruby
  * Create the rvm gemset that metacon will run under and
    install some gems into it
  * Install into it the actual metacon gem
  * Attempt to make a symlink for the gem's metacon binary
    in /usr/local/bin to override rubygem's normal
    executable handling and to make sure it's available no
    matter what rvm gemset you happen to be in.

EOF

read -p "Continue (y/n)? "
[ "$REPLY" == "y" ] || exit 1

set -e

MCON_RUBY_V="ruby-1.9.2"

if [[ $EUID == 0 ]]; then
  echo "You are running this as a superuser. I recommend against that if possible." 1>&2
  read -p "Continue anyway (y/n)? "
  [ "$REPLY" == "y" ] || exit 1
fi

[[ `git --version` ]] || ( echo "Metacon requires 'git' (git-core package if deb/ubu). Please install and retry." && exit 1 )
[[ `curl --version` ]] || ( echo "Metaon requires 'curl'. Please install and retry." && exit 1 )

set +e
if [[ ! `rvm version` ]]; then
  echo "RVM not found. Attempting to install."
  bash < <(curl -s https://raw.github.com/wayneeseguin/rvm/master/binscripts/rvm-installer ) || exit 2
  INSTALLED_RVM=1
else
  echo "RVM found"
  INSTALLED_RVM=
  source "$HOME/.rvm/scripts/rvm"
  rvm get head
  rvm reload
fi

source "$HOME/.rvm/scripts/rvm"
[[ `rvm use $MCON_RUBY_V` == *Using* ]] || ( rvm install $MCON_RUBY_V && rvm use $MCON_RUBY_V ) || exit 3
rvm use $MCON_RUBY_V
[[ `rvm use $MCON_RUBY_V; rvm gemset use metacon 2>&1` == *ERROR* ]] && ( ( rvm use $MCON_RUBY_V && rvm gemset create metacon && rvm gemset use metacon ) || exit 3 )
rvm gemset use metacon
rvm current
rvm --force gemset empty metacon || exit 3

set -e
GEMOUT=`mktemp /tmp/metacon.XXXXXX`
gem install metacon | grep -v metacon-installer | grep -v "^$" | tee $GEMOUT
DIRNAME=`grep 'Successfully installed metacon-' $GEMOUT | cut -d' ' -f3`
unlink $GEMOUT
TMPGEMDIR=`rvm gemdir`

set +e
echo "Trying to set up metacon binary in /usr/local/bin"
rm -f /usr/local/bin/metacon &> /dev/null || sudo rm -f /usr/local/bin/metacon
ln -s ${TMPGEMDIR}/gems/${DIRNAME}/bin/metacon /usr/local/bin/metacon &> /dev/null || \
  sudo ln -s ${TMPGEMDIR}/gems/${DIRNAME}/bin/metacon /usr/local/bin/metacon
set -e

if [ $INSTALLED_RVM ]; then
	echo "To finish installing RVM you need to add the following to your .bashrc (or .bash_profile etc.) - then restart the shell."
	echo "echo '[[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm" # Load RVM function' >> ~/.bash_profile"
fi
