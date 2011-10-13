class String; def as_version; MetaCon::CLIHelpers::SymVer.new(self) end end

module MetaCon
  module CLIHelpers

    class SymVer
      include Comparable
      attr_accessor :varr
      def initialize(vstring)
        @varr = vstring.split('.').map{|p| p.to_i}
      end

      def <=>(other_v)
        (0..[other_v.varr.size,@varr.size].max).each do |i|
          s = @varr[i] || 0
          o = other_v.varr[i] || 0
          if s < o then return -1
          elsif s > o then return 1 end
        end
        return 0
      end
    end

    CONTEXT_OS = `uname -s`.strip.downcase.to_sym
    def mac?()    CONTEXT_OS == :darwin end
    def darwin?() CONTEXT_OS == :darwin end
    def linux?()  CONTEXT_OS == :linux  end

    ESCS = {:normal    =>"\e[0m",    :black     =>"\e[0;30m", :blue         =>"\e[0;34m",
            :green     =>"\e[0;32m", :cyan      =>"\e[0;36m", :red          =>"\e[0;31m",
            :purple    =>"\e[0;35m", :brown     =>"\e[0;33m", :gray         =>"\e[0;37m",
            :dark_gray =>"\e[1;30m", :light_blue=>"\e[1;34m", :light_green  =>"\e[1;32m",
            :light_cyan=>"\e[1;36m", :light_red =>"\e[1;31m", :light_purple =>"\e[1;35m",
            :yellow    =>"\e[1;33m", :white     =>"\e[1;37m", :bg_black     =>"\e[40m",
            :bg_red    =>"\e[41m",   :bg_green  =>"\e[42m",   :bg_yellow    =>"\e[43m",
            :bg_blue   =>"\e[44m",   :bg_magenta=>"\e[45m",   :bg_cyan      =>"\e[46m",
            :bg_white  =>"\e[47m",   :"="       =>"\e[44;1;37m", :"=="      =>"\e[4;1;37m",
            :"==="     =>"\e[1;34m"}

    def color_puts(str, emit=true)
      begin
        r = false
        str.gsub!(/\|\{([^ \|]+ )([^\}\|]*)\}/){r=true; "#{ESCS[$1.strip.to_sym]}#{$2}#{ESCS[:normal]}"}
      end while r
      puts str if emit
      return str
    end

    def cwarn(str) color_puts("---|{brown Warning:} #{str}") end
    def cfail(str) color_puts("---|{red Fail:} #{str}") end

    def status(str) color_puts("\n---|{== #{str}}") end
    def result(str) color_puts("   |{green #{str}}\n") end

    def fj(*args) File.expand_path(File.join(args)) end # Shortcut for File.join

    def chd(*args)
      dir = f(args)
      color_puts "|{gray cd #{dir}}"
      Dir.chdir(dir)
    end

    def command_exists?(cmd)
      `( command -v #{cmd} )`.length > 0
    end

    def check_tool(name, vcmd, vpos=1, vexp='0', inst='', wmissing=false, wvers=true)
      vs = `#{vcmd}`
      if vs.length > 0
        v = vs.strip.split(/\s+/)[vpos - 1]
        require 'pp'
        if v.as_version < vexp.as_version
          if wvers
            cwarn("#{name} expected to be >= version #{vexp} but only #{v} found. You may need to upgrade.")
            return false
          else
            cfail("#{name} expected to be >= version #{vexp} but only #{v} found. Please upgrade.")
          end
        end
      else
        if wmissing
          cwarn("#{name} not found. To install: #{inst}")
        else
          cfail("#{name} not found. To install: #{inst}")
          return false
        end
      end
      return true
    end

    def shellescape(str)
      return "''" if str.empty?
      str = str.dup
      str.strip!
      str.gsub!(/([^A-Za-z0-9_\-.,:\/@\n])/n, "\\\\\\1")
      str.gsub!(/\n/, "'\n'")
      return str
    end

    def best_profile_file
      prof = Dir[ENV['HOME']+'/.bashrc']
      prof = Dir[ENV['HOME']+'/.zshrc'] if prof.size == 0
      prof = Dir[ENV['HOME']+'/.bash_profile'] if prof.size == 0
      prof = Dir[ENV['HOME']+'/.profile'] if prof.size == 0
      return prof[0] unless prof.size == 0
      return nil
    end
  end
end

