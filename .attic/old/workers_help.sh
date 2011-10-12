#/usr/bin/env bash

# TODO:
#  - cd()
#  - adjust prompt
#  - autocomplete

export VIRTUAL_ENV_DISABLE_PROMPT=true


function __worker_ps1() {
  rnd=`od -N1 -A n -b /dev/random`
  worker_type="gamer_transcode"${rnd/ /}
  worker_env="d"
  status="c"
  printf "${1:-(%s/%s/%s)}" "$worker_type" "$worker_env" "$status"
}



__WORKER_PS1='$(__worker_ps1)'"$PS1"
PS1=$__WORKER_PS1
