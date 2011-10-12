# Meta-dependencies (depended on by metacon)
  - git
  - ruby
  - rvm
  - supervisord (?)
(and if there are any python / pip dependencies or subs that need them):
  - python
  - pythonbrew

(Perhaps only installed lazily as needed by the conf options?)
(also something inserted into .bashrc etc. for autocompletion and ps1
alterations)


# Installation type
## 1. general
  - Discouraged if possible because then different environments are no longer
    isolated.
  - Not allowed if different roles require different versions (in which case
    one would be encouraged to turn it into a submodule and run prebuilt local
    versions instead).
  - Can block switching to a different environment if the machine doesn't have
    the correct version required for that other environment.
Defined by:
  * Command to check if tool exists
  * Command for figuring out what version the tool is at currently
  * Command for testing the tool, if desired- in a global context or local to
   the project.
  * Command for seeing which versions are available for installation
  * Installation hints or commands (if any divergences from the standard installchain)

Examples:
  * git-core, imagemagick...


### Installchain
#### Preferred tool heirarchy per OS & dependency-type. 
  * Test to see if dependency tool is available and working correctly (has
    correct permissions etc.)
  * Looks for individual preference overrides (e.g., yes, I have brew, but I
    prefer you try w/ macports first... etc.)
  * Ability to do a rehearsal - shows what seems to be missing and what would
    probably be used to install it.

## 2. language
  - Initially support isolated versions for:
    * ruby - via rvm
    * python - via python-brew
  - At some point should be pretty easy to add to that list:
    * perl (via perlbrew)
    * gcc (via ???)
    * anything that's usually switchable via ubuntu's update-alternatives (? -
      assuming we can do it in isolated environments at the same time)
  - These would need to get checked against their respective tools (rvm etc.)
    to see which versions are available etc. and warnings issued if something
    else was chosen
Defined by:
  * Command for seeing which versions are available for installation

## 3. sub (git submodule)
 - When switching roles or environment symlink for submodule directory changes,
   which means the .metacon/bin/ added to the users search path (??) is also
   now looking at the one for the other role/env/etc.

Defined by:
  * (Will look for actual location via git locally and create one if
    necessary(?)...)
  * Branch
  * Commit (if not head)
  * mini-installation commands
    - build
    - rebuild
    - test
    - (start/stop/restart/sync/deploy ?)
    - 

## 4. git (?)
  - Don't know if this is really going to be useful as something separate from
    "general" yet.
  - Could populate list of available versions etc. etc. straight from github
    (including private via private keys etc.)

## 5. gem (ruby module)
  - Together they take the place of, for example, Gemfile + Gemfile.lock files

## 6. pip (python module)
  - Together they take the place of pip dependency list files


##

  Type: submodule


