module MetaCon
  module Loaders
    module Helpers
      def included(by); by.extend(self) end
      def shcmd(cmd_string, echo=true)
        require 'open3'
        main_out = ''
        err_out = ''
        exit_status = 1
        $stout.puts(cmd_string) if echo
        Open3.popen3('/usr/bin/env bash -s') do |stdin, stdout, stderr, wth|
          stdin.puts cmd_string
          stdin.flush
          stdin.close
          loop do
            ready, _, exc = IO.select [stdout, stderr], [], [stdout, stderr], 5000
            ready.map!{|str| str.fileno}
            if (!stdout.eof?) && ready.include?(stdout.fileno)
              more = stdout.readpartial(4096)
              if echo
                $stdout.print more
                $stdout.flush
              end
              main_out += more
            elsif (!stderr.eof?) && ready.include?(stderr.fileno)
              more = stderr.readpartial(4096)
              if echo
                $stderr.print more
                $stderr.flush
              end
              err_out += more
            else break end
            break if (stderr.eof? && stdout.eof?)
          end
          if wth.nil? then exit_status = err_out.length > 0 ? 1 : 0  # Best guess
          else exit_status = wth.value.to_i end
        end
        return [main_out, err_out, exit_status]
      end
      extend self
    end
  end
end
