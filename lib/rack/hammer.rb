require 'rack'
require 'benchmark'
require 'ruby-prof'

module Rack
  class Hammer < Rack::Server
    class Options
      def parse!(args)
        options = {}
        opt_parser = OptionParser.new("", 24, '  ') do |opts|
          opts.banner = "Usage: hammer [ruby options] [rack options] [hammer options] [rackup config]"

          opts.separator ""
          opts.separator "Ruby options:"

          opts.on("-d", "--debug", "set debugging flags (set $DEBUG to true)") {
            options[:debug] = true
          }
          opts.on("-w", "--warn", "turn warnings on for your script") {
            options[:warn] = true
          }

          opts.on("-I", "--include PATH",
                  "specify $LOAD_PATH (may be used more than once)") { |path|
            options[:include] = path.split(":")
          }

          opts.on("-r", "--require LIBRARY",
                  "require the library, before executing your script") { |library|
            options[:require] = library
          }

          opts.separator ""
          opts.separator "Rack options:"
          opts.on("-E", "--env ENVIRONMENT", "use ENVIRONMENT for defaults (default: development)") { |e|
            options[:environment] = e
          }

          opts.separator ""
          opts.separator "Hammer options:"
          opts.on("-u", "--uri URI", "path to hammer (default: /)") { |u|
            options[:uri] = u
          }
          
          opts.on("-m", "--mode MODE", "hammer mode (benchmark/profile)") { |m|
            options[:mode] = m
          }
          
          opts.on("-p", "--printer FORMAT", "ruby-prof printer (see ruby-prof --help)") { |p|
            options[:printer] = p
          }
          
          opts.on("-f", "--file FILE", "ruby-prof output file (default: STDOUT)") { |f|
            options[:file] = f
          }
          
          opts.on("-i", "--iterations ITERATIONS", "times to make the request (default: 10)") { |i|
            options[:iterations] = i
          }
          
          opts.on("-M", "--minimum MINIMUMPERCENT", "minimum percentage to report (default: 10)") { |m|
            options[:minimum] = m
          }
          
          opts.separator ""
          opts.separator "Common options:"

          opts.on_tail("-h", "--help", "Show this message") do
            puts opts
            exit
          end

          opts.on_tail("--version", "Show version") do
            puts "hammer #{Rack::HammerVersion}"
            exit
          end
        end
        opt_parser.parse! args
        options[:config] = args.last if args.last
        options
      end
    end
      
    class << self
      def hammer(options = nil)
        new(options).hammer
      end      
    end
    
    def hammer
      send(options[:mode]||'benchmark')
    end
    
    def profile
      # Rehearsal
      do_request
      
      ::RubyProf.start
      iterations.times { do_request }
      result = ::RubyProf.stop
      result.eliminate_methods!([/Rack::Hammer#iterations/, /Rack::Hammer#request/, /Rack::Server#app/, /Integer#times/])
      
      case options[:printer]
        when 'flat_with_line_numbers'
          printer = ::RubyProf::FlatPrinterWithLineNumbers
        when 'graph'
          printer = ::RubyProf::GraphPrinter
        when 'graph_html'
          printer = ::RubyProf::GraphHtmlPrinter
        when 'call_tree'
          printer = ::RubyProf::CallTreePrinter
        when 'call_stack'
          printer = ::RubyProf::CallStackPrinter
        when 'dot'
          printer = ::RubyProf::DotPrinter
        else # :flat
          printer = ::RubyProf::FlatPrinter
      end
      
      file = options[:file] ? ::File.open(options[:file], 'w') : STDOUT
      
      printer.new(result).print(file, :min_percent => minimum)
    end
    
    def minimum
      @minimum ||= options[:minimum].to_i.to_i == 0 ? 10 : options[:minimum].to_i
    end
    
    def iterations
      @iterations ||= options[:iterations].to_i.to_i == 0 ? 10 : options[:iterations].to_i
    end
    
    def benchmark
      # Instantiate app now so it doesn't STDERR all over our benchmark
      app
      
      Benchmark.bmbm do |bm|
        bm.report("#{iterations} requests") { iterations.times { do_request } }
      end
    end
    
    def request
      @request ||= Rack::MockRequest.env_for(options[:uri]||'/')
    end
    
    def do_request
      app.call(request)
    end
    
    private
      def opt_parser
        Options.new
      end
  end
end
