module MetaCon
  class Project
    require 'metacon/config'
    attr_accessor :mc_dir, :rel_dir, :root_dir, :valid
    def self.initialized?(relative_to='./')
      ! find_mc_dir(relative_to).nil?
    end

    def initialize(relative_to='./')
      @rel_dir = File.expand_path(relative_to)
      @mc_dir = Project.find_mc_dir(@rel_dir)
      if @mc_dir.nil?
        @root_dir = nil
        @valid = false
        @state = nil
      else
        @root_dir = File.expand_path(File.join(@mc_dir, '..'))
        @valid = true
        @state = SavedState.new(@mc_dir)
      end
    end

    def this_os; `uname -s`.strip.downcase end
    def this_host; `uname -n`.strip end

    def different_os?

    end

    def atomic(&block)
      @state.atomic do |s|
        yield self, s
      end
    end

    def switch(changes={})
      return :nochange if changes=={}
      return :impossible unless can_switch?
      changed = false
      @state.atomic do |s|
        changes.each do |key, val|
          s[key] = val unless s[key] == val
        end
        changed = s.dirty
      end
      if changed
        return setup_context
      else
        return :nochange
      end
    end

    def can_switch?
      # TODO: make sure submodules don't have stuff to stash etc.
      return true
    end

    def current_state
      st = @state.readonly
      st[:os] = this_os if (st[:os] == '(this)' || st[:os] == '.')
      st[:host] = this_host if (st[:host] == '(this)' || st[:host] == '.')
      return st
    end

    def list(to_list)
      return nil unless @valid
      refresh_conf
      cs = current_state
      @conf.declared[to_list].keys | [cs[to_list]]
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

    def refresh_conf; @conf = Config.new(@root_dir) end

    def setup_context
      # Dependencies loaded in for:
      # - ruby
      # - gems
      # - bundler Gemfiles
      # - python
      # - pips
      # - submodules
      # - (general tools)
      # Use different classes for each to encourage adding more

      return :switched
    end
  end

  class SavedState
    require 'yaml'
    attr_accessor :dirty
    def initialize(mcdir)
      raise "#{mcdir} not found" unless File.directory?(mcdir)
      @fstate = File.join(mcdir,'current_state')
      @in_atomic = @dirty = false
    end

    def blank_initial_state
      @dirty = true
      {:role => 'main',
       :rtc => 'dev',
       :os => '(this)',
       :host => '(this)'}
    end

    def atomic(&block)
      @in_atomic = true
      `touch #{@fstate}` # Guarantee exists and change timestamps
      File.open(@fstate,'r+') do |f|
        f.flock File::LOCK_EX
        @state = YAML::load(f.read)
        @state ||= blank_initial_state
        yield self
        if @dirty
          f.pos = 0
          f.print @state.to_yaml
          f.truncate(f.pos)
        end
      end
      @dirty = false
      @in_atomic = false
    end

    def readonly
      res = YAML::load_file(@fstate)
      res ||= blank_initial_state
      return res
    end

    def [](key)
      if @in_atomic
        @state[key]
      end
    end

    def []=(key,val)
      if @in_atomic
        @state[key] = val
        @dirty = true
      end
    end
  end
end
