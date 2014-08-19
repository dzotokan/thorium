#!/usr/bin/env ruby

require 'thor'
require 'thor/group'

module ApacheCLI
  class Apache < Thor
    package_name 'Thorium | Apache'

    include Thor::Actions

    class_option :verbose, :type => :boolean, :default => 1
    class_option :sudo, :type => :boolean, :default => 1
    class_option :ctl_method, :enum => ['apachectl', 'apache2ctl', 'service'], :default => 'apachectl'

    desc "ctl [ARGS]", "Apache controller wrapper"
    long_desc <<-LONGDESC
      `start`     - Starts apache
      `stop`      - Stops apache
      `restart`   - Restarts apache
      `graceful`  - Restarts apache gracefully
      `status`    - Apache status
      > $ ctl restart
    LONGDESC
    def ctl(*args)
      command = "#{options[:ctl_method]} #{args * ' '}"
      command = 'sudo ' + command if options[:root] == 1
      run(command, {:verbose => options[:verbose], :capture => false})
    end

    no_commands {

    }
  end
end

module GitCLI
  class Git < Thor
    package_name 'Thorium | Git'

    include Thor::Actions

    class_option :verbose, :type => :boolean, :default => 1

    desc "list", "List Github repositories"
    def list
      require 'json'
      username = ask("Github username: ")
      github_url = "https://api.github.com/users/#{username}/repos"
      github_repos_filepath = ENV['HOME'] + "/.thorium/github_repos_#{username}.json"
      # Get repos from github api
      get github_url, github_repos_filepath
      # Save response in a file
      response_json = File.read(github_repos_filepath)
      response_hash = JSON.parse(response_json)
      puts "#{username}'s repositories (name, ssh url, clone url)"
      puts "====================================================="
      print_table response_hash.map { |e| e.values_at("name", "ssh_url", "clone_url") }
    end

  end
end


module ThoriumCLI
  # Main tasks class
  class Thorium < Thor
    package_name 'Thorium'

    include ApacheCLI
    include GitCLI

    @@os = ENV['_system_type']

    class_option :verbose, :type => :boolean, :default => false

    desc "hello", "This command says hello to Thorium!"
    def hello
      name = ask("What is your name?")
      puts "Hello #{name}! Hello from Thorium!"
    end

    desc "apache [SUBCOMMAND] [ARGS]", "Control Apache with ease!"
    subcommand "apache", Apache

    desc "git [SUBCOMMAND] [ARGS]", "Git wrapper"
    subcommand "git", Git
  end
end


ThoriumCLI::Thorium.start(ARGV)