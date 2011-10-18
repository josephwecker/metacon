module MetaCon
  class Config
    attr_accessor :data, :declared
    def initialize(root)
      require 'yaml'
      conf_files = Dir[root + '/**/*.mconf']
      @data = {}
      @declared = {:runctx=>{}, :role=>{}, :os=>{}, :machine=>{}}
      conf_files.each{|cf| update_with(cf) }
    end

    def update_with(fname)
      default_family = File.basename(fname,'.mconf')
      content = YAML.load_file(fname)
      return unless content
      content.each{|k,v| update_group(default_family, k, v)}
    end

    def update_group(default_family, key, content)
      if key.start_with? '/'
        # TODO: Actually parse these- negative namespaces, regex, etc.
        runctx, role, os, machine = key.split('/').map{|v| v.strip}[1..-1]
        @declared[:runctx][runctx] = true unless runctx == '*'
        @declared[:role][role] = true unless role == '*'
        @declared[:os][os] = true unless os == '*'
        @declared[:machine][machine] = true unless machine == '*'
        # TODO: populate data
      elsif content.is_a?(Hash)
        content.each{|k,v| update_group(key,k,v) }
      end
    end
  end
end
