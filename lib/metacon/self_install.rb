module MetaCon
  class SelfInstall
    include MetaCon::CLIHelpers

    EXP_GIT_V = '1.7.4.1'
    EXP_RVM_V = '1.8.2'
    EXP_PYB_V = '1.1'

    def check_install
      exit 2 unless check_git
      result 'Looks good'

      exit 3 unless check_rvm
      result 'Looks good'

      exit 4 unless check_pythonbrew
      result 'Looks good'

      install_shelp
    end

    def check_git
      status('Checking git')
      return check_tool('Git', 'git --version', 3, EXP_GIT_V,
                        'http://book.git-scm.com/2_installing_git.html')
    end

    def check_rvm
      status('Checking rvm')
      return check_tool('RVM', 'rvm --version', 2, EXP_RVM_V,
                        'http://beginrescueend.com/rvm/install/')
    end

    def check_pythonbrew
      status ('Checking pythonbrew')
      return check_tool('Python-brew','pythonbrew --version', 1, EXP_PYB_V,
                        'https://github.com/utahta/pythonbrew/blob/master/README.rst')
    end

    def install_shelp
      status "Checking shell helper functionality"
      
      shelp = File.join(File.dirname(__FILE__), '..','..', 'shelp','metacon.bashrc')
      if File.exists?(shelp)
        result "Not yet implemented- you're good to go"
      else
        cfail "Couldn't find shell helper files (metacon.bashrc) - installation broken somehow..."
        exit 5
      end
    end
  end
end
