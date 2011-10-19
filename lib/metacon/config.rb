module MetaCon
  class Config
    attr_accessor :data, :declared
    def initialize(root)
      # TODO: Ability to explicitly set mconf files in .metacon settings
      require 'yaml'
      conf_files = Dir[root + '/**/*.mconf']
      @data = []
      @declared = {:rtc=>{}, :role=>{}, :os=>{}, :host=>{}}
      conf_files.each{|cf| update_with(cf) }
    end

    def [](context)
      rtc,role,os,host = [:rtc,:role,:os,:host].map{|k| context.delete(k) || '*'}
      relevant = @data.select do |keys,fc|
        (rtc == '*' || keys[0] == '*' || rtc == keys[0]) &&
        (role== '*' || keys[1] == '*' || role== keys[1]) &&
        (os  == '*' || keys[2] == '*' || os  == keys[2]) &&
        (host== '*' || keys[3] == '*' || host== keys[3])
      end
      res = {}
      relevant.each do |k, fc|
        fam, content = fc
        if res.has_key?(fam)
          currv = res[fam]
          if content.is_a?(Array) && currv.is_a?(Array)
            res[fam] = currv | content
          elsif content.is_a?(Hash) && currv.is_a?(Hash)
            res[fam] = currv.merge(content)
          else
            # TODO: Think through more merge scenarios
            raise "Could not combine conf parameters for #{fam}"
          end
        else res[fam] = content end
      end
      return res
    end

    protected

    def update_with(fname)
      default_family = File.basename(fname,'.mconf')
      content = YAML.load_file(fname)
      return unless content
      content.each{|k,v| update_group(default_family, k, v)}
    end

    def update_group(default_family, key, content)
      if key.start_with? '/'
        # TODO: Actually parse these- negative namespaces, regex, etc.
        rtc, role, os, host = key.split('/').map{|v| v.strip}[1..-1]
        @declared[:rtc][rtc] = true unless rtc == '*'
        @declared[:role][role] = true unless role == '*'
        @declared[:os][os] = true unless os == '*'
        @declared[:host][host] = true unless host == '*'
        @data << [[rtc,role,os,host],[default_family, content]]
      elsif content.is_a?(Hash)
        content.each{|k,v| update_group(key,k,v) }
      end
    end
  end
end
