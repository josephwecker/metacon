# Components
## General Commandline

## Commands
 - st / stat  -> environment + versions of dependencies, state of submodules,
   current git state, running state, etc.
 - env     [-l[ist] || new\_env]
 - role    [-l[ist] || new\_role]
 - machine [-l[ist] || impersonate\_machine]
 - os (shows current only?)
 - br / branch [...] -> alias for git-branch so its clear it's an intergral part of
   the current operating environment

 - run/start [@as-options]  [cmd...options...]
 - stop
 - restart (gracefully)
 - hard-restart (ungracefully)
 - test (starts supervisord in non-daemon mode if it's not already running for
   additional feedback)

## Config
 - Allow a ~/.metacon-config for filling in general things not specified in
   project directory.
 - project.config > home.config > default.config
 - Make sure there is general (sane) config stuff for basic ruby-god stuff

## Shell Prompt (PS1) for Bash/ZSH

## Autocomplete


