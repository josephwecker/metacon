module MetaCon
  class Stat
    include MetaCon::CLIHelpers
    def self.handle(cli, cmd, opts)
      case cmd
      when :stat; stat(cli, opts)
      when :curr; curr(cli, opts)
      end
    end

    def self.stat(cli, opts)
      puts '(not yet implemented)'
      curr(cli, opts)
    end

    def self.curr(cli, opts)
      proj = MetaCon::Project.new
      cfail 'Not a metacon project. Use `metacon init`' and exit(5) unless proj.valid
      state = proj.current_state
      os = state[:os] == proj.this_os ? '.' : state[:os]
      machine = state[:machine] == proj.this_machine ? '.' : state[:machine]
      puts "/#{state[:runctx]}/#{state[:role]}/#{os}/#{machine}/"
    end
  end
end
