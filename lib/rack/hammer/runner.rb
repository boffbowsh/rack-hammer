require 'rack/server'

module Rack
  module Hammer
    class Runner
      def initialize config, path
        @config = config
        @path = path
      end
      
      def server
        @server ||= Rack::Server.new
      end
      
      def default_options
        {
          :environment => "development",
          :pid         => nil,
          :Port        => 9292,
          :Host        => "0.0.0.0",
          :AccessLog   => [],
          :config      => "config.ru"
        }
      end
      
      def run
        
      end
    end
  end
end