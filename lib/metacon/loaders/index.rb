
# TODO:
#   - rvm:ruby           [DONE 0.2.2]
#   - pythonbrew:python
#   - pythonbrew:pip
#   - gitsubmodules:sub
#   ----
#   - rvm:gem
#   ----
#   - bundler
#   - general-tools (apt/homebrew/etc.)
#

module MetaCon
  module Loaders
    module Index
      require 'metacon/loaders/rvm'
      require 'metacon/loaders/python_brew'
      #require 'metacon/loaders/general_git_submodules'
      LOADERS = {
        'ruby'   => MetaCon::Loaders::RVM,
        'gem'    => MetaCon::Loaders::RVM,
        'python' => MetaCon::Loaders::PythonBrew
        #:pip    => MetaCon::Loaders::PythonBrew,
        #:sub    => MetaCon::Loaders::GeneralGitSubmodules
      }
    end
  end
end
