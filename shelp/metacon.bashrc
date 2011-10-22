#!/usr/bin/env bash
# TODO: make sure not to show role in prompt if no role differentiation is used.
# TODO: put rvm and pythonbrew "source" lines here in case they weren't
#       installed beforehand so there's only one line to add to the user's
#       bashrc etc.

mvm(){
  # Essentially just let metacon do its thing but then do in the current
  # context anything it tells us to do (such as setting environment variables)
  tmpout=`mktemp /tmp/mc.XXXXXXXX`
  metacon -s $@ | tee $tmpout | grep -v '^:bash'  # Run & display results
  eval `grep '^:bash' $tmpout | cut -d' ' -f2-`   # Process any bash commands
  unlink $tmpout
}


