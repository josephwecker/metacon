module MetaCon
  class Project
    require 'metacon/config'
    require 'metacon/loaders/index'
    include MetaCon::Loaders::Index
    include MetaCon::Shorthand
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

    # Options that it cares about:
    #   - :verbose   true/false
    #   - :shell     true/false
    def switch(changes={},opts={})
      return :nochange if changes=={}
      return :impossible unless can_switch?
      changed = false
      @state.atomic do |s|
        changes.each{|key, val| s[key]=val unless s[key]==val }
        changed = s.dirty
      end
      if changed then return setup_context(opts)
      else return :nochange end
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

    def full_context
      res = {}
      res[:root_dir] = @root_dir
      o,e,s = shcmd(["cd \"#{@root_dir}\"",
                     "source '#{MetaCon::shelp_dir}/git-completion.bash'",
                     "export GIT_PS1_SHOWUPSTREAM=\"auto\"",
                     "export GIT_PS1_SHOWDIRTYSTATE=1",
                     "export GIT_PS1_SHOWUNTRACKEDFILES=1",
                     "export GIT_PS1_SHOWSTASHSTATE=1",
                     "__git_ps1 \"%s\""].join(' && '), false)
      git_br = o.strip.split(/\s+/)
      git_codes = git_br.pop
      git_brname = git_br.join(' ')
      res[:git_branch] = git_brname
      res[:git_upstream] =
        case
        when git_codes.include?('<>'); :diverged
        when git_codes.include?('<'); :behind
        when git_codes.include?('>'); :ahead
        else :same
        end
      res[:git_has_stashed] = git_codes.include?('$')
      res[:git_has_unstaged] = git_codes.include?('*')
      res[:git_has_staged] = git_codes.include?('+')
      res[:git_has_changes] = res[:git_has_staged] || res[:git_has_unstaged]
      pwd = File.expand_path(Dir.pwd)
      res[:pwd_from_root] = relative_path(@root_dir,pwd)
      cs = current_state
      res[:runtime_context] = cs[:rtc]
      res[:role] = cs[:role]
      res[:os] = cs[:os]
      res[:machine] = cs[:host]
      res[:name] = res[:root_dir].split('/').last.strip
      res[:metadir] = "{#{res[:name]}}/#{res[:pwd_from_root]}"
      res[:user] = `whoami`.strip
      return res
    end

    def summary_str
    end

    def ps1(color=true)
      fc = full_context

      #---- project-name
      parts = [fc[:name]]

      #---- git-branch
      style = []
      style << 'underline' if fc[:git_branch] == 'master'
      style << ({:diverged => 'fg_blue',
                    :behind   => 'fg_yellow',
                    :ahead    => 'fg_green'}[fc[:git_upstream]] || 'fg_default')
      gitbr =  "<|reset|#{style.join('|')}>#{fc[:git_branch]}<|reset|>"
      # yes, these are actually orthoganal, but this precedence makes more
      # sense for the UI.
      if fc[:git_has_unstaged]   then gitbr << '<|bright>*<|reset>'
      elsif fc[:git_has_staged]  then gitbr << '<|bright>+<|reset>'
      elsif fc[:git_has_stashed] then gitbr << '<|bright>$<|reset>' end
      parts << gitbr

      #---- runtime-context
      r = fc[:runtime_context]
      style = []
      style << 'fg_red' if r[/^prod|hot/i]
      style << 'bright' if r[/^prod|hot/i]
      style << 'fg_green' if r[/^dev/i]
      style << 'fg_yellow' if r[/test/i]
      style << 'fg_cyan' if r[/staging|deploy/i]
      parts << "<|reset|#{style.join('|')}>#{r}<|reset|>"

      #---- the rest
      parts << (fc[:role] == 'main' ? '~' : "<|reset>#{fc[:role]}")
      parts << (fc[:os] == this_os ?  '~' : "<|reset>#{fc[:os]}")
      parts << (fc[:machine] == this_host ?  '~' : "<|reset>#{fc[:machine]}")


      line = "<|reset|bright|fg_black>(<|reset|underline>#{parts.join('<|reset|bright|fg_black>/')}<|bright|fg_black>)<|reset>/#{fc[:pwd_from_root]}<|bright|fg_black>-><|reset> "

      return MetaCon::CLIHelpers.cstr2(line)
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

    def setup_context(opts)
      # TODO: if there is no ruby or python dependency, switch them to some
      # "neutral"/default version + packages so the user doesn't accidentally
      # pollute an env-specific gemset etc.
      # TODO: read in all the dependencies first to calculate
      # interdependencies. For example, make sure that the ruby version is
      # switched before any gems are installed, etc. This'll have to be
      # abstracted somehow for the add-on libraries.
      dependencies = self.conf['dependencies'] || []
      incomplete = false
      emitted = {}
      dependencies.each do |dep|
        orig_dep = dep.dup
        dep = dep.split('/').map{|part| part.strip}
        kind = dep[0].downcase
        loader = LOADERS[kind]
        if loader.nil?
          unless emitted[kind]
            $stderr.puts "WARNING: Don't know how to work with '#{kind}' dependencies." if opts[:verbose]
            emitted[kind] = true
            incomplete = true
          end
        else
          unless loader.load_dependency(dep, @state.state, self, opts)
            $stderr.puts "ERROR: Failed to load #{orig_dep} - continuing anyway"
            incomplete = true
          end
        end
      end
      return incomplete ? :incomplete : :switched
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
