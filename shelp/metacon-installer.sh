#!/usr/bin/env bash

# TODO:
#  - install the metacon gem (in metacon's ruby+gemset)
#  - look at output to installation - find full path for .metacon_unwrapped
#  - make a 'metacon' bin or symlink one that wraps .metacon_unwrapped w/ rvm exec


set -e

MCON_RUBY_V="ruby-1.9.2"

if [[ $EUID == 0 ]]; then
  echo "You are running this as a superuser. I recommend against that if possible." 1>&2
  read -p "Continue anyway (y/n)? "
  [ "$REPLY" == "y" ] || exit 1
fi

[[ `git --version` ]] || ( echo "Metacon requires 'git' (git-core package if deb/ubu). Please install and retry." && exit 1 )
[[ `curl --version` ]] || ( echo "Metaon requires 'curl'. Please install and retry." && exit 1 )

if [[ ! `rvm version` ]]; then
  echo "RVM not found. Attempting to install."
  bash < <(curl -s https://raw.github.com/wayneeseguin/rvm/master/binscripts/rvm-installer ) || exit 2
  INSTALLED_RVM=1
else
  echo "RVM found"
  INSTALLED_RVM=
fi

source "$HOME/.rvm/scripts/rvm"
set +e
[[ `rvm use $MCON_RUBY_V` == *Using* ]] || ( rvm install $MCON_RUBY_V && rvm use $MCON_RUBY_V ) || exit 3
rvm use $MCON_RUBY_V
[[ `rvm use $MCON_RUBY_V; rvm gemset use metacon 2>&1` == *ERROR* ]] && ( ( rvm use $MCON_RUBY_V && rvm gemset create metacon && rvm gemset use metacon ) || exit 3 )
rvm gemset use metacon
rvm current
rvm --force gemset empty metacon || exit 3

set -e
GEMOUT=`mktemp /tmp/metacon.XXXXXX`
gem install metacon | tee $GEMOUT
DIRNAME=`grep 'Successfully installed metacon-' $GEMOUT | cut -d' ' -f3`
unlink $GEMOUT

rm -f /usr/local/bin/metacon /usr/local/bin/.metacon_unwrapped
ln -s `rvm gemdir`/gems/${DIRNAME}/bin/metacon /usr/local/bin/metacon

if [ $INSTALLED_RVM ]; then
	echo "To finish installing RVM you need to add the following to your .bashrc (or .bash_profile etc.) - then restart the shell."
	echo "echo '[[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm" # Load RVM function' >> ~/.bash_profile"
fi
