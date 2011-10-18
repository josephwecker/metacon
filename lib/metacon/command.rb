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
      :st => :stat,
      :stat => :stat,
      :status => :stat,
      :statistics => :stat,
      :c => :curr,
      :curr => :curr,
      :current => :curr,
      :init => :init,
      :initialize => :init,
      :role => :role,
      :context => :runctx,
      :ctx => :runctx,
      :runcontext => :runctx
    }
    COMMANDS = {:init => {:opt_args => ['directory'],
                          :desc => 'Init metacon project dir, default ./, create if necessary',
                          :handler => MetaCon::Init},
                :stat => {:opt_args => ['stat-name'],
                          :desc => 'Status of / information about the current context',
                          :handler => MetaCon::Stat},
                :curr => {:opt_args => ['kind'],
                          :desc => 'Display current metacontext (or specified part)',
                          :handler => MetaCon::Stat},
                :role => {:opt_args => ['-list', 'switch-to'],
                          :desc => 'Show current role, list available roles, or switch.',
                          :handler => MetaCon::Switch},
                :rctx => {:opt_args => ['-list', 'switch-to'],
                          :desc => 'Show current run-context, list available, or switch.',
                          :handler => MetaCon::Switch},
                :os =>   {:opt_args => ['-list', 'switch-to'],
                          :desc => 'Show current OS, list available, or try to switch.',
                          :handler => MetaCon::Switch},
                :machine=>{:opt_args => ['-list', 'switch-to'],
                           :desc => 'Show current machine, list defined, or try to switch.',
                           :handler => MetaCon::Switch}
               }
    def self.run
      banner = "metacon\n"+
               "MetaController version #{MetaCon::VERSION}\n" +
               "Usage: metacon [COMMAND] [OPTIONS]"
      options = {}
      opts = OptionParser.new do |o|
        o.version = MetaCon.version
        o.banner = banner
        o.separator ''
        o.on('-v', '--[no-]verbose', 'Run command verbosely'){|v| options[:verbose]=v}

        o.on('-h','--help', 'Show this message'){puts o; exit 0}
        o.on('--version', 'Show version and exit'){puts MetaCon::VERSION; exit 0}

        o.separator ''
        o.separator 'commands          '
        o.separator '------------------'
        cmds = COMMANDS.map do |c,p|
          opt_args = p[:opt_args].map{|oa| "[#{oa.upcase}]"}.join(' ')
          "#{(c.to_s + ' ' + opt_args).ljust(36)} #{p[:desc]}"
        end
        o.separator cmds
      end
      rest = opts.parse(ARGV)

      if rest.size == 0
        puts opts
        exit
      end
      command_key = rest.shift.strip.downcase
      command = CMD_ALIASES[command_key.to_sym]

      if command.nil?
        cfail "Command #{command_key} not found. Use -h to see the list of commands."
        exit 2
      end
      cli = HighLine.new
      command_info = COMMANDS[command]
      command_info[:handler].send :handle, cli, command, rest
    end
  end
end
