module MetaCon
    module Shorthand
      def included(by); by.extend(self) end
      def shcmd(cmd_string, echo=true)
        require 'open3'
        main_out = ''
        err_out = ''
        exit_status = 1
        $stdout.puts(cmd_string) if echo
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

      # Make a path relative (relative to the initial path)
      def relative_path(initial,dest)
        dest = File.expand_path(dest).split('/')
        initial = File.expand_path(initial)
        initial = File.dirname(initial) unless File.directory?(initial)
        initial = initial.split('/')
        pref,a,b = common_prefix(dest,initial)
        return (b.map{|d|'..'} + a).join('/')
      end

      # Take two arrays and return an array holding the common prefix and then
      # the remainder for each of the originals.
      def common_prefix(a,b)
        res = []
        (0..[a.size,b.size].max).each do |i|
          if a[i] == b[i]; res << a[i]
          else break end
        end
        return [res, a[res.size..-1] || [], b[res.size..-1] || []]
      end

    extend self
  end
end
