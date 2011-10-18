module MetaCon
  class Command
    require 'optparse'
    require 'highline'
    require 'metacon/init'
    COMMANDS = {:init => {:opt_args => ['directory'],
                          :desc => 'Initialize metacon project dir (default ./), creates if necessary',
                          :handler => MetaCon::Init}}
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
      command = COMMANDS[command_key.to_sym]
      if command.nil?
        $stderr.puts "Command #{command_key} not found. Use -h to see the list of commands."
        exit 2
      end
      cli = HighLine.new
      command[:handler].send :handle, cli, rest
    end
  end
end
