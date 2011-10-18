module MetaCon
  class Init
    require 'fileutils'
    def self.handle(cli, opts)
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
      else FileUtils.mkdir(mcd) end
  
      puts "OK, putting stuff in it..."
      mcp = MetaCon::Project.new(mcd)

      described = mcp.defined_roles
      initial_role = described.size==0 ? 'main' : described[0]
      described = mcp.defined_contexts
      initial_context = described.size==0 ? 'dev' : described[0]
      mcp.switch(:role => initial_role, :ctx => initial_context)
    end
  end
end
