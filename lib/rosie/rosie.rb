module Rosie
  class Rosie

    def self.run argv
      self.get_parser argv
    end

    def self.print_help_and_die option_parser
      $stderr.print option_parser.help
      exit
    end

    private
    def self.get_parser argv
      options = {}
      
      global = OptionParser.new do |opts|
        opts.banner = 'Usage: rosie [options] [subcommand [options] [subcommand [options]]]'
        opts.on('-u', '--url [URL]', 'Jenkins CI url') do |v|
          options[:url] = v
        end

        opts.on('-h', '--help', 'Display app help') do |v|
          options[:help] = v
        end
      end

      # Handle empty arguments
      print_help_and_die global unless !argv.empty?
      global.order! argv
      # Print help whenever it has been requested,
      # regardless of all the other options
      print_help_and_die global if options[:help]

      commands = {
        'show' => OptionParser.new do |opts|
          opts.banner = 'show [options] subcommand [options]'
          opts.on('-v', '--verbose', 'Run verbosely') do |v|
            options[:show] = {}
            options[:show][:verbose] = v
          end
        end
      }

      subcommands = {
        'show' => {
          'failures' => OptionParser.new do |opts|
            opts.banner = 'failures [options]'
            opts.on('', '--view [VIEW]', 'Specify which view to use') do |v|
              options[:show] = {}
              options[:show][:failures] = {}
              options[:show][:failures][:view] = v
            end
          end
        }
      }

      command = argv.shift
      # When there's an invalid command, print the help for all the
      # available commands and exit afterwards.
      if not commands.has_key? command
        commands.each do |k, v|
          $stderr.print v.help
        end
        exit
      end

      command_parser = commands[command]
      command_parser.order! argv
      print_help_and_die command_parser unless not argv.empty?

      subcommand = argv.shift
      if not subcommands[command].has_key? subcommand
        subcommands[command].each do |_, v|
          $stderr.print v.help
        end
        exit
      end

      subcommand_parser = subcommands[command][subcommand]
      subcommand_parser.order! argv

      # Display a summary of all the commands and subcommands that
      # have been given until now and exit
      if not argv.empty?
        $stderr.print global.help
        $stderr.puts
        $stderr.print command_parser.help
        $stderr.puts
        $stderr.print subcommand_parser.help
        exit
      end
    end
  end
end
