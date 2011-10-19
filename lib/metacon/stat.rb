module MetaCon
  class Stat
    def self.handle(cmd, opts)
      case cmd
      when :stat; stat(opts)
      when :curr; curr(opts)
      end
    end

    def self.stat(opts)
      puts '(not yet implemented)'
      puts curr(opts)
    end

    def self.curr(opts=[], proj=nil)
      proj ||= $proj
      $cli.cfail 'Not a metacon project. Use `metacon init`' and exit(5) unless proj.valid
      state = proj.current_state
      os = state[:os] == proj.this_os ? '.' : state[:os]
      host = state[:host] == proj.this_host ? '.' : state[:host]
      if opts.size == 0
        puts "/#{state[:rtc]}/#{state[:role]}/#{os}/#{host}/"
      else
        # TODO: check for valid types
        opts.each{|o| puts state[o.to_sym]}
      end
    end
  end
end
