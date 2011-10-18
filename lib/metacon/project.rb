module MetaCon
  class Project
    require 'metacon/config'
    attr_accessor :mc_dir, :rel_dir, :root_dir
    def self.initialized?(relative_to='./')
      ! find_mc_dir(relative_to).nil?
    end

    def initialize(relative_to='./')
      @rel_dir = File.expand_path(relative_to)
      @mc_dir = Project.find_mc_dir(@rel_dir)
      @root_dir = File.expand_path(File.join(@mc_dir, '..'))
      if @mc_dir.nil?
        @valid = false
      else
        @valid = true
        @state = SavedState.new(@mc_dir)
      end
    end

    def defined_roles
      return nil unless @valid
      refresh_conf
      #@conf.roles
    end

    def defined_contexts
      return nil unless @valid
      refresh_conf
    end

    def switch(changes={})
      return true if changes=={}

      return false
    end

    protected
    def self.find_mc_dir(relative_to='./')
      d = relative_to.dup
      while ! File.directory?(File.join(d,'.metacon'))
        d = File.expand_path(File.join(d,'..'))
        return nil if d == '/'
      end
      return File.join(d,'.metacon')
    end

    def refresh_conf
      @conf = Config.new(@root_dir)
    end
  end

  class SavedState
    def initialize(mcdir)
      raise "#{mcdir} not found" unless File.directory?(mcdir)
      @fstate = File.join(mcdir,'current_state')
    end
  end
end
