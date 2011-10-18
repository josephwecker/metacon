module MetaCon
  class Init
    require 'fileutils'
    include MetaCon::CLIHelpers
    def self.handle(cli, _cmd, opts)
      dir = opts.shift
      dir ||= './'
      # Find out if different roles are specified. If none- default to primary.
      # Default to dev
      # Run context-shift/verify

      if MetaCon::Project.initialized?(dir)
        exit(3) unless cli.agree('This is already part of a metacon project. Continue? (y/n)', true)
      end

      already_there = false
      mcd = File.join(dir,'.metacon')
      if File.directory?(dir)
        already_there = File.directory?(mcd)
      else FileUtils.mkdir_p(dir) end
      if already_there
        exit(3) unless cli.agree('Refresh existing .metacon directory? (y/n) ', true)
        `rm -rf "#{mcd}"`
      end
      FileUtils.mkdir(mcd)

      status "Initializing..."
      mcp = MetaCon::Project.new(mcd)

      described = mcp.defined_roles
      initial_role = described.size==0 ? 'main' : described[0]
      described = mcp.defined_contexts
      initial_context = described.size==0 ? 'dev' : described[0]
      switch_res = mcp.switch(:role => initial_role, :runctx => initial_context)
      if switch_res == :impossible
        cfail 'Cannot initialize the metacontext- submodules need to have files committed.'
        exit 4
      end

      result "\"#{dir}\" is now a metacon project"
    end
  end
end
