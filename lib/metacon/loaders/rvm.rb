module MetaCon
  module Loaders
    class RVM
      require 'metacon/loaders/helpers'
      include MetaCon::Loaders::Helpers
      include MetaCon::CLIHelpers
      def self.load_dependency(dependency_parts, state, proj, opts)
        kind = dependency_parts.shift
        if kind == 'ruby'
          ruby = fix_ruby_version(dependency_parts)
          return switch_ruby(ruby, state, opts)
        elsif kind == 'gem'

        else
          raise "I don't handle #{kind} dependencies... am I missing something?"
        end
      end


      RVMS = "source $HOME/.rvm/scripts/rvm && "

      def self.switch_ruby(ruby, state, opts={})
        unless check_installed(ruby,opts)
          unless install(ruby,opts)
            cfail "Failed to install ruby '#{ruby}'"
            return false
          end
        end
        gemset = fix_gemset_name(state)
        unless check_gemset_installed(gemset, opts)
          unless create_gemset(ruby, gemset, opts)
            cfail "Failed to create a gemset '#{gemset}' for '#{ruby}'"
            return false
          end
        end
        return switch(ruby, gemset, opts)
      end


      def self.check_installed(ruby, opts)
        o,e,s = cmd "#{RVMS} rvm use '#{ruby}'", opts[:verbose]
        return (s==0 && o =~ /using/i)
      end

      def self.check_gemset_installed(ruby, gemset, opts)
        o,e,s = cmd "#{RVMS} rvm use '#{ruby}' && rvm gemset use '#{gemset}'", opts[:verbose]
        return (s == 0 && e.strip.length == 0)
      end

      def self.install(ruby, opts)
        o,e,s = cmd "#{RVMS} rvm install #{ruby}", opts[:verbose]
        return (s == 0 && check_installed(ruby,opts))
      end

      def self.create_gemset(ruby, gemset, opts)
        o,e,s = cmd "#{RVMS} rvm use '#{ruby}' && rvm gemset create '#{gemset}'", opts[:verbose]
        res = (o =~ /created/i) && (s == 0) && (e.strip.length == 0)
        return false unless res
        # TODO: Make sure any "permanent" prereqs are loaded (possibly
        # metacon?)
        return true
      end

      def self.switch(ruby, gemset, opts)
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
        return true
      end

      protected

      def self.fix_ruby_version(parts)
        return parts[0].downcase=='head' ? 'ruby-head' : parts.join('-')
      end

      def self.fix_gemset_name(state)
        return "mcon_#{clean(state[:rtc])}__#{clean(state[:role])}"
      end

      def self.clean(s)
        s.gsub /[^a-zA-Z0-9_]+/, '_'
      end
    end
  end
end
