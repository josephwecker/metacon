module MetaCon
  module Loaders
    class RVM
      include MetaCon::Shorthand
      include MetaCon::CLIHelpers
      def self.load_dependency(dependency_parts, state, proj, opts)
        kind = dependency_parts.shift
        if kind == 'ruby'
          # TODO: check for and install rvm for when this is used outside of
          # the main installed command context.
          ruby = fix_ruby_version(dependency_parts)
          return switch_ruby(ruby, state, opts)
        elsif kind == 'gem'

        else
          raise "I don't handle #{kind} dependencies... am I missing something?"
        end
      end


      RVMS = "source $HOME/.rvm/scripts/rvm && "
      def self.shc(cmdstr,v); return shcmd("#{RVMS} #{cmdstr}", v) end

      def self.switch_ruby(ruby, state, opts={})
        # TODO: shortcircuit all of this by trying to construct the environment path
        # and look there first - then do all of this if it doesn't exist.
        unless check_installed(ruby,opts)
          unless install(ruby,opts)
            cfail "Failed to install ruby '#{ruby}'"
            return false
          end
        end
        gemset = fix_gemset_name(state)
        unless check_gemset_installed(ruby, gemset, opts)
          unless create_gemset(ruby, gemset, opts)
            cfail "Failed to create a gemset '#{gemset}' for '#{ruby}'"
            return false
          end
        end
        return switch(ruby, gemset, opts)
      end


      def self.check_installed(ruby, opts)
        o,e,s = shc("rvm use '#{ruby}@'", false)
        return (s==0 && o =~ /using/i)
      end

      def self.check_gemset_installed(ruby, gemset, opts)
        o,e,s = shc("rvm use '#{ruby}'@'#{gemset}'", false)
        return (s == 0 && e.strip.length == 0)
      end

      def self.install(ruby, opts)
        o,e,s = shc("rvm install #{ruby}", opts[:verbose])
        return (s == 0 && check_installed(ruby,opts))
      end

      def self.create_gemset(ruby, gemset, opts)
        o,e,s = shc("rvm use '#{ruby}' && rvm gemset create '#{gemset}'", opts[:verbose])
        res = (o =~ /created/i) && (s == 0) && (e.strip.length == 0)
        return res
        #return false unless res
        # TODO: Make sure any "permanent" prereqs are loaded (possibly
        # metacon?)
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
        o,e,s = shc("rvm '#{ruby}'@'#{gemset}' do rvm tools identifier", false)
        identstr = o.strip
        envsettings = "~/.rvm/environments/#{identstr}"
        cmds = process_env_commands(IO.readlines(File.expand_path(envsettings)))
        puts cmds.join("\n") if opts[:shell]
        return true
      end

      protected

      def self.process_env_commands(cmdlines,and_exec=true)
        res = []
        cmdlines.each do |cl|
          if cl =~ /^\s*export\s+PATH="([^"]+)"/
            res << process_path_mod($1.split(':'),and_exec)
          elsif cl =~ /^\s*unset /
            res << ":bash #{cl.strip}"
            ENV.delete(cl.split(/\s+/)[1..-1].join(' ')) if and_exec
          elsif cl =~ /export /
            if and_exec
              val = cl.split("'")[1]
              name = cl.split('=')[0].strip
              ENV[name] = val
            end
            res << ":bash #{cl.strip}"
          else
            raise "Don't know what to do with the environment command: #{cl}"
          end
        end
        return res
      end

      def self.process_path_mod(parts, and_exec)
        require 'shellwords'
        currpath = ENV['PATH'].split(':')
        parts.delete('$PATH')
        currpath.select!{|v| v !~ /\/\.rvm\//}
        rewritten = (parts + currpath).join(':')
        ENV['PATH'] = rewritten if and_exec
        return ":bash export PATH=\"#{Shellwords.shellescape(rewritten)}\""
      end

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
