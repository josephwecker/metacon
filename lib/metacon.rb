module MetaCon
  require 'metacon/cli_helpers'
  require 'metacon/command'
  require 'metacon/project'
  VERSION = File.exist?(File.join(File.dirname(__FILE__),'VERSION')) ?
    File.read(File.join(File.dirname(__FILE__),'VERSION')) : ""
  class << self
    def version() VERSION end
  end
end
