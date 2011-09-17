module MetaCon
  class Command
    require 'optparse'
    def self.run
      banner = "metacon\n"+
               "MetaController version #{MetaCon::VERSION}\n" +
               "Usage: metacon [command] [options]"
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
        o.separator commands.map{|c,p| "#{c.to_s.ljust(15)}#{p[:desc]}"}
      end

      files = opts.parse(ARGV)
    end

    def self.commands
      [[:init, {:desc=>'Initialize ./ or specified directory as a metacon directory, creating it if necessary.',
                 :opt_arg=>'[DIRECTORY]'}]
      ]
    end
  end
end
