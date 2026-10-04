#!/usr/bin/env ruby
# frozen_string_literal: true
# Name:         shuji (Shuttle/SSH Hosts Unix JSON Importer)
# Version:      0.1.6
# Release:      1
# License:      CC BY-NC-SA 4.0 (Creative Commons Attribution-NonCommercial-ShareAlike)
#               https://creativecommons.org/licenses/by-nc-sa/4.0/legalcode
# Group:        System
# Source:       N/A
# URL:          http://github.com/lateralblast/shuji
# Distribution: UNIX
# Vendor:       UNIX
# Packager:     Richard Spindler <richard@lateralblast.com.au>
# Description:  Imports hosts file into a JSON based config file for Shuttle SSH [1]
#               [1] https://fitztrev.github.io/shuttle/

# Required modules

# Require a module, installing its gem first if it is not present

def require_or_install(lib, gem_name = lib)
  require lib
rescue LoadError
  puts "Installing required Ruby module: #{gem_name}"
  abort "Failed to install #{gem_name}, try: gem install #{gem_name}" unless system('gem', 'install', '--user-install', gem_name)

  Gem.clear_paths
  begin
    require lib
  rescue LoadError
    abort "Installed #{gem_name} but could not load #{lib}"
  end
end

require_or_install('getopt/std', 'getopt')
require_or_install('json')

OPTIONS          = 'hi:jo:sT:tVl:'
DEFAULT_INPUT    = '/etc/hosts'
DEFAULT_SSH_CONF = File.join(ENV.fetch('HOME'), '.ssh', 'config')
DEFAULT_TERMINAL = 'iTerm.app'
DEFAULT_ON_BOOT  = true
# Lines starting with a comment, loopback, broadcast or IPv6 address are ignored
SKIP_PATTERN     = /^#|^127|^255|^f|^:/.freeze
TERMINAL_DIRS    = ['/Applications', '/Applications/Utilities'].freeze

# Read a field from the "# Field:" header comments of this script

def header_field(field)
  line = File.readlines(__FILE__).grep(/^# #{field}/).first
  line.split(':')[1].strip
end

def get_version
  "#{header_field('Name')} v. #{header_field('Version')} #{header_field('Packager')}"
end

# Print the version of the script

def print_version
  puts
  puts get_version
  puts
end

# Print information regarding the usage of the script

def print_usage
  puts
  puts "Usage: #{$PROGRAM_NAME} -[#{OPTIONS}]"
  puts
  puts "-V:\tDisplay version information"
  puts "-h:\tDisplay usage information"
  puts "-i:\tImport file (default #{DEFAULT_INPUT}, or #{DEFAULT_SSH_CONF} with -s)"
  puts "-s:\tImport file is an SSH config file rather than a hosts file"
  puts "-o:\tOutput file (default ~/.shuttle.json, implies -j)"
  puts "-j:\tConvert hosts file to a JSON file"
  puts "-t:\tOutput to standard IO"
  puts "-T:\tSet Terminal application (default #{DEFAULT_TERMINAL})"
  puts "-l:\tStart Shuttle at login (default #{DEFAULT_ON_BOOT})"
  puts
end

# Parse a hosts file line into [host_name, domain_name, user_name], or nil if it should be skipped

def parse_host_line(line)
  line = line.strip
  return if line.match?(SKIP_PATTERN) || !line.match?(/[a-z]|[0-9]/)

  host_part, comment = line.split('#', 2)
  host_info = host_part.to_s.split(/\s+/)
  return if host_info.length < 2

  host_name, *domain_parts = host_info[1].split('.')
  domain_name = domain_parts.empty? ? 'local' : domain_parts.join('.')
  user_name   = comment.to_s.split.first.to_s
  [host_name, domain_name.capitalize, user_name]
end

# Return the domain (menu name) of a host name, IP addresses and short names are "Local"

def domain_of(host_name)
  return 'Local' if host_name.to_s.match?(/\A[\d.]+\z|:/) || !host_name.to_s.include?('.')

  host_name.split('.')[1..].join('.').capitalize
end

# Parse an SSH config file into [alias, domain_name, user_name] entries

def parse_ssh_config(input_file)
  entries = []
  current = []
  File.foreach(input_file) do |line|
    line = line.strip
    next if line.empty? || line.start_with?('#')

    keyword, value = line.split(/\s*=\s*|\s+/, 2)
    value = value.to_s.strip.delete('"')
    case keyword.downcase
    when 'host'
      # Wildcard and negated patterns are not connectable hosts
      current = value.split.reject { |name| name.match?(/[*?!]/) }.map { |name| [name, 'Local', ''] }
      entries.concat(current)
    when 'hostname'
      current.each { |entry| entry[1] = domain_of(value) }
    when 'match'
      current = []
    end
  end
  entries
end

# Build the Shuttle menu entry for a host

def host_entry(host_name, user_name)
  target = user_name.match?(/[A-Za-z]/) ? "#{user_name}@#{host_name}" : host_name
  { 'name' => host_name, 'cmd' => "ssh #{target}" }
end

# Convert a hosts file (or SSH config file) to Shuttle JSON, returns the JSON string

def hosts_to_json(input_file, on_boot, terminal, ssh_config: false)
  domains = Hash.new { |hash, key| hash[key] = [] }
  entries = if ssh_config
              parse_ssh_config(input_file)
            else
              File.foreach(input_file).map { |line| parse_host_line(line) }.compact
            end
  entries.each do |host_name, domain_name, user_name|
    domains[domain_name] << host_entry(host_name, user_name)
  end
  JSON.pretty_generate(
    '_comment1'       => "Shuttle SSH JSON config file created by #{get_version}",
    'terminal'        => terminal,
    'launch_at_login' => on_boot,
    'hosts'           => domains.map { |domain, list| { domain => list } }
  )
end

# Validate the terminal application name and return it without the .app suffix

def resolve_terminal(name)
  terminal = name.sub(/\.app$/, '')
  return terminal if TERMINAL_DIRS.any? { |dir| File.exist?("#{dir}/#{terminal}.app") }

  abort "Terminal application #{terminal} does not exist"
end

def parse_options
  Getopt::Std.getopts(OPTIONS)
rescue StandardError
  print_usage
  exit
end

def main
  opt = parse_options

  if opt['h']
    print_usage
    exit
  elsif opt['V']
    print_version
    exit
  end

  # Require an explicit output choice so that nothing is overwritten by accident
  unless opt['t'] || opt['j'] || opt['o']
    print_usage
    exit
  end

  input_file = opt['i'] || (opt['s'] ? DEFAULT_SSH_CONF : DEFAULT_INPUT)
  abort "File: #{input_file} does not exist" unless File.exist?(input_file)

  terminal    = opt['T'] ? resolve_terminal(opt['T']) : DEFAULT_TERMINAL.sub(/\.app$/, '')
  on_boot     = opt['l'] ? !opt['l'].match?(/\A(no|false|0)\z/i) : DEFAULT_ON_BOOT
  output_file = opt['o'] || File.join(ENV.fetch('HOME'), '.shuttle.json') unless opt['t']

  # Build the JSON before opening the output file so a failure cannot truncate it
  output = hosts_to_json(input_file, on_boot, terminal, ssh_config: opt['s'])

  if output_file
    File.write(output_file, output)
  else
    puts output
  end
end

main if $PROGRAM_NAME == __FILE__
