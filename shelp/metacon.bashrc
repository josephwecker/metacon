#!/usr/bin/env bash
# TODO: make sure not to show role in prompt if no role differentiation is used.

mcon(){
  # Essentially just let metacon do its thing but then do in the current
  # context anything it tells us to do (such as setting environment variables)
  eval `metacon -s $@ | grep '^:bash' | cut -d' ' -f2-`
}
