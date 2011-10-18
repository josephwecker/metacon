module MetaCon
  class Config
    attr_accessor :data
    def initialize(root)
      require 'yaml'
      conf_files = Dir[root + '/**/*.mconf']
      @data = {}
      conf_files.each{|cf| update_with(cf) }
    end

    def update_with(fname)
      default_family = File.basename(fname,'.mconf')
      content = YAML.load_file(fname)
      content.each{|k,v| update_group(k,v)}
    end

    def update_group(default_family, key, content)
      if key.start_with? '/'
        # TODO: you are here- populate @data[family][meta-env]...
      elsif content.is_a?(Hash)
        content.each{|k,v| update_group(key,k,v) }
      end
    end
  end
end
