
# TODO: if the --shell flag is sent in, essentially do the following:
#       * Use rvm info to figure out the correct root directory
#       * Find .rvm/environments/... for the currently selected ruby+gemset
#       * Compare actual $PATH to what it would need to change to so that we
#         don't keep prepending to PATH and growing it needlessly on every
#         switch.
#       * Create replacement 'export path' stmt
#       * Take all stmts and concatenate w/ ';' and shell escape where
#         appropriate (esp. newlines at least)
#       * Prepend full string w/ 'bash: ' so that it gets evalled in the
#         current context.
#       * Enjoy!
module MetaCon
  module Loaders
    class RVM
      require 'metacon/loaders/helpers'
      include MetaCon::Loaders::Helpers
      include MetaCon::CLIHelpers
      def self.ensure(dep, state, proj, v=true)
        kind = dep.shift
        if kind == 'ruby'
          vstr = dep[0].downcase=='head' ? 'ruby-head' : dep.join('-')
          switch_ruby(vstr)
        elsif kind == 'gem'

        else
          raise "I don't handle #{kind} dependencies... am I missing something?"
        end
      end

      def self.switch_ruby(version, v=true)
        # TODO: Be sure and always select a gemset
        # TODO: Make sure metacon is always installed in that gemset
        select_res, err_txt, st = cmd "rvm use '#{version}'", v
        select_res += err_txt
        if st == 0 && select_res =~ /rvm install (.*)/
          real_version = $1
          if install_ruby(real_version,v) then return switch_ruby(real_version)
          else return(false) end
        elsif select_res =~ /Using/i then return true
        else return(false) end
      end

      def self.install_ruby(version, v=true)
        inst_res, err_txt, st = cmd "rvm install '#{version}'", v
        return st == 0 && err_text.strip.length == 0
      end
    end
  end
end
