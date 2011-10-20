module MetaCon
  class Init
    require 'fileutils'
    def self.handle(_cmd, clo, opts)
      dir = opts.shift
      dir ||= './'
      # Find out if different roles are specified. If none- default to primary.
      # Default to dev
      # Run context-shift/verify

      if MetaCon::Project.initialized?(dir)
        exit(3) unless $cli.agree('This is already part of a metacon project. Continue? (y/n)', true)
      end

      already_there = false
      mcd = File.join(dir,'.metacon')
      if File.directory?(dir)
        already_there = File.directory?(mcd)
      else FileUtils.mkdir_p(dir) end
      if already_there
        exit(3) unless $cli.agree('Refresh existing .metacon directory? (y/n) ', true)
        `rm -rf "#{mcd}"`
      end
      FileUtils.mkdir(mcd)

      $cli.status "Initializing..." if clo[:verbose]
      mcp = MetaCon::Project.new(mcd, clo[:verbose])

      init_role = mcp.list(:role)[0] || 'main'
      init_rtc  = mcp.list(:rtc)[0] || 'dev'
      switch_res = mcp.switch(true, {:role => init_role, :rtc => init_rtc})
      if switch_res == :impossible
        $cli.cfail 'Cannot initialize the metacontext- submodules need to have files committed.'
        exit 4
      end
      $cli.result "\"#{dir}\" is now a metacon project" if clo[:verbose]
    end
  end
end
