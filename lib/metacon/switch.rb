module MetaCon
  class Switch
    def self.handle(cmd, clo, opts)
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
        res = $proj.switch({cmd=>opts[0]}, clo)
        case res
        when :nochange
          $cli.cwarn 'Nothing changed' if clo[:verbose]
        when :switched
          $cli.result "Switched #{cmd} to '#{opts[0]}'" if clo[:verbose]
        when :incomplete
          $cli.cwarn "Not all dependencies loaded."
          $cli.result "Switched #{cmd} to '#{opts[0]}' more or less." if clo[:verbose]
        when :impossible
          $cli.cfail 'Cannot switch. Probably because submodules need committing.'
        end
        MetaCon::Stat.curr(opts,$proj,clo)
      end
    end
  end
end
