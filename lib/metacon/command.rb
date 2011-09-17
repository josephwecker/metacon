module MetaCon
  class Command
    def self.run
      require 'pp'
      pp ARGV
    end
  end
end
