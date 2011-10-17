module MetaCon
  class Init
    def self.handle(opts)
      dir = opts.shift
      dir ||= './'
    end
  end
end
