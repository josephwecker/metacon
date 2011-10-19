module MetaCon
  class Switch
    def self.handle(cmd, opts)
      if opts.nil? or opts.size == 0
        all = $proj.list(cmd)
        current = $proj.current_state[cmd]
        all.sort.each do |avail|
          if avail == current
            $cli.cputs "* |{green #{avail}}"
          else
            puts "  #{avail}"
          end
        end
      else
        res = $proj.switch({cmd=>opts[0]})
        case res
        when :nochange
          $cli.cwarn 'Nothing changed'
        when :switched
          $cli.result "Switched #{cmd} to '#{opts[0]}'"
        when :impossible
          $cli.cfail 'Cannot switch. Probably because submodules need committing.'
        end
        MetaCon::Stat.curr
      end
    end
  end
end
