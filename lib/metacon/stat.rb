module MetaCon
  class Stat
    def self.handle(cmd, clo, opts)
      case cmd
      when :stat; stat(opts, clo)
      when :curr; curr(opts, nil, clo)
      end
    end

    def self.stat(opts, clo)
      puts '(not yet implemented)'
      puts curr(opts)
    end

    def self.curr(opts=[], proj=nil, clo)
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
