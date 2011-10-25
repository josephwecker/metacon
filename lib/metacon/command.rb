
# TODO:
#  - "up" / "refresh" - something to redo dependencies etc. etc. as if context
#    had just changed.
module MetaCon
  class Command
    require 'optparse'
    require 'metacon/cli_helpers'
    require 'highline'
    require 'metacon/init'
    require 'metacon/stat'
    require 'metacon/switch'
    include MetaCon::CLIHelpers
    CMD_ALIASES = {
      :init =>       :init,
      :initialize => :init,

      :st =>         :stat,
      :stat =>       :stat,
      :status =>     :stat,
      :statistics => :stat,

      :c =>          :curr,
      :curr =>       :curr,
      :current =>    :curr,

      :role =>       :role,

      :rtc =>        :rtc,
      :rctx =>       :rtc,
      :runtime =>    :rtc,
      :runtimecontext => :rtc,

      :os =>         :os,
      :operatingsystem => :os,

      :host =>       :host,
      :machine =>    :host,
      :computer =>   :host,
      :server =>     :host,

      :conf =>       :conf,
      :config =>     :conf,
      :configuration=> :conf,

      :prompt =>     :ps1,
      :ps1 =>        :ps1
    }
    COMMANDS = [[:init, {:args => ['[DIRECTORY]'],
                          :desc => 'Init metacon project dir, default ./, create if necessary',
                          :handler => MetaCon::Init}],
                [:stat, {:args => ['[STAT-NAME]'],
                          :desc => 'Status of / information about the current context',
                          :handler => MetaCon::Stat}],
                [:curr, {:args => ['[KIND]'],
                          :desc => 'Display current metacontext (or specified part)',
                          :handler => MetaCon::Stat}],
                [:role, {:args => ['[SWITCH-TO]'],
                          :desc => 'Show current role in list, or switch to new.',
                          :handler => MetaCon::Switch}],
                [:rtc,  {:args => ['[SWITCH-TO]'],
                          :desc => 'Show current runtime-context in list, or switch to new.',
                          :handler => MetaCon::Switch}],
                [:os,   {:args => ['[SWITCH-TO]'],
                          :desc => 'Show current OS in list, or try to switch to new.',
                          :handler => MetaCon::Switch}],
                [:host, {:args => ['[SWITCH-TO]'],
                         :desc => 'Show current host/machine in list, or try to switch to new.',
                         :handler => MetaCon::Switch}],
                [:conf, {:args => ['[FAMILY]'],
                         :desc => 'Output the currently applicable configuration',
                         :handler => MetaCon::Command}],
                [:ps1,  {:args => [],
                         :desc => 'Emit value appropriate for ps1 prompt',
                         :handler => MetaCon::Command}] ]
    def self.run
      banner = "metacon\n"+
               "MetaController version #{MetaCon::VERSION}\n" +
               "Usage: metacon [COMMAND] [OPTIONS]"
      options = {}
      opts = OptionParser.new do |o|
        o.version = MetaCon.version
        o.banner = banner
        o.separator ''
        o.on('-q', '--[no-]quiet', 'Run command quietly'){|v| options[:verbose]= !v}

        o.on('-h','--help', 'Show this message'){puts o; exit 0}
        o.on('--version', 'Show version and exit'){puts MetaCon::VERSION; exit 0}

        o.on('-s', '--[no-]shell-output', 'Outputs commands for evaluating in the current shell') do |v|
          options[:shell]=v
        end

        o.separator ''
        o.separator 'commands          '
        o.separator '------------------'
        cmds = COMMANDS.map do |c,p|
          args = p[:args].join(' ')
          "#{(c.to_s + ' ' + args).ljust(36)} #{p[:desc]}"
        end
        o.separator cmds
      end
      rest = opts.parse(ARGV)
      options[:shell] = false if options[:shell].nil?
      options[:verbose] = true if options[:verbose].nil?

      if rest.size == 0
        puts(opts)
        exit
      end

      command_key = rest.shift.strip.downcase
      command = CMD_ALIASES[command_key.to_sym]
      if command.nil?
        cfail "Command #{command_key} not found. Use -h to see the list of commands."
        exit 2
      end

      $cli = HighLine.new
      $cli.extend(MetaCon::CLIHelpers)
      $proj = nil
      unless [:init].include?(command)
        $proj = MetaCon::Project.new('./', options[:verbose])
        unless $proj.valid || (command == :ps1)
          $cli.cfail 'Not a metacon project. Use `metacon init`'
          exit 5
        end
      end

      command_info = COMMANDS.select{|k,v| k == command}[0][1]
      command_info[:handler].send :handle, command, options, rest
    end

    def self.handle(cmd,clo,opts)
      if cmd == :conf
        conf = $proj.conf
        conf = Hash[opts.map{|fam| [fam, conf[fam]]}] if opts.size > 0
        puts conf.to_yaml
      elsif cmd == :ps1
        puts ps1
      end
    end

    def self.ps1(color=true)
      return `echo "$ORIG_PS1"` unless $proj.valid
      fc = $proj.full_context

      #---- project-name
      parts = [fc[:name]]

      #---- git-branch
      style = []
      style << 'underline' if fc[:git_branch] == 'master'
      style << ({:diverged => 'fg_blue',
                    :behind   => 'fg_yellow',
                    :ahead    => 'fg_green'}[fc[:git_upstream]] || 'fg_default')
      gitbr =  "<|reset|#{style.join('|')}>#{fc[:git_branch]}<|reset|>"
      # yes, these are actually orthoganal, but this precedence makes more
      # sense for the UI.
      if fc[:git_has_unstaged]   then gitbr << '<|bright>*<|reset>'
      elsif fc[:git_has_staged]  then gitbr << '<|bright>+<|reset>'
      elsif fc[:git_has_stashed] then gitbr << '<|bright>$<|reset>' end
      parts << gitbr

      #---- runtime-context
      r = fc[:runtime_context]
      style = []
      style << 'fg_red' if r[/^prod|hot/i]
      style << 'bright' if r[/^prod|hot/i]
      style << 'fg_green' if r[/^dev/i]
      style << 'fg_yellow' if r[/test/i]
      style << 'fg_cyan' if r[/staging|deploy/i]
      parts << "<|reset|#{style.join('|')}>#{r}<|reset|>"

      #---- the rest
      parts << (fc[:role] == 'main' ? '~' : "<|reset>#{fc[:role]}")
      parts << (fc[:os] == $proj.this_os ?  '~' : "<|reset>#{fc[:os]}")
      parts << (fc[:machine] == $proj.this_host ?  '~' : "<|reset>#{fc[:machine]}")


      line = "<|reset|bright|fg_black>(<|reset|underline>#{parts.join('<|reset|bright|fg_black>/')}<|bright|fg_black>)<|reset>/#{fc[:pwd_from_root]}<|bright|fg_black>-><|reset> "

      return MetaCon::CLIHelpers.cstr2(line)
    end
  end
end
