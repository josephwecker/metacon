module MetaCon
  module Loaders
    class PythonBrew
      require 'metacon/loaders/helpers'
      include MetaCon::Loaders::Helpers
      include MetaCon::CLIHelpers
      def self.load_dependency(dependency_parts, state, proj, opts)
        kind = dependency_parts.shift
        if kind == 'python'
          # Ensure pythonbrew installed / current
          # Make sure that python is installed
          # Make sure this has its venv installed
          # Select via env variables etc.
        elsif kind == 'pip'

        else
          raise "I don't handle #{kind} dependencies... am I missing something?"
        end
        
      end
    end
  end
end
