module MetaCon
  class Project
    require 'metacon/config'
    require 'metacon/loaders/index'
    include MetaCon::Loaders::Index
    attr_accessor :mc_dir, :rel_dir, :root_dir, :valid
    def self.initialized?(relative_to='./')
      ! find_mc_dir(relative_to).nil?
    end

    def uid
      if @uid.nil?
        require 'digest/sha1'
        key = self.this_host + @state[:role] + @state[:rtc] + @state[:host] + @state[:os]
        @uid = Digest::SHA1.hexdigest(key)[0..5]
      end
      @uid
    end

    def initialize(relative_to='./', verbose=true)
      @verbose = verbose
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
        refresh_conf
      end
    end

    def conf_obj; @config end
    def conf; @config[current_state] end

    def this_os
      @@this_os ||= `uname -s`.strip.downcase
      @@this_os
    end

    def this_host
      @this_host ||= `uname -n`.strip
      @this_host
    end

    def switch(verbose=false,changes={})
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
        return setup_context(verbose)
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
      cs = current_state
      @config.declared[to_list].keys | [cs[to_list]]
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

    def refresh_conf; @config = Config.new(@root_dir) end

    def setup_context(verbose=false)
      dependencies = self.conf['dependencies']
      incomplete = false
      dependencies.each do |dep|
        dep = dep.split('/').map{|part| part.strip}
        kind = dep[0].downcase
        loader = LOADERS[kind]
        if loader.nil?
          $stderr.puts "WARNING: Don't know how to work with '#{kind}' dependencies." if verbose
          incomplete = true
        else
          loader.ensure(dep, @state.state, self)
        end
      end
      return incomplete ? :incomplete : :switched
      # TODO: Handle :incomplete in calling modules
    end
  end

  class SavedState
    require 'yaml'
    attr_accessor :dirty, :state
    def initialize(mcdir)
      raise "#{mcdir} not found" unless File.directory?(mcdir)
      @fstate = File.join(mcdir,'current_state')
      @in_atomic = @dirty = false
      @state = nil
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
      if File.exists?(@fstate)
        res = YAML::load_file(@fstate)
        res ||= blank_initial_state
      else
        res = blank_initial_state
      end
      return res
    end

    def [](key)
      if @in_atomic
        @state[key]
      elsif @state.nil?
        @state = readonly
      else
        @state[key]
      end
    end

    def []=(key,val)
      if @in_atomic
        @state[key] = val
        @dirty = true
      else
        atomic do |s|
          s[key] = val
        end
      end
    end
  end
end
