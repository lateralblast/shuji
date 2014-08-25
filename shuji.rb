#!/usr/bin/env ruby
# Name:         shuji (Shuttle/SSH Hosts Unix JSON Importer)
# Version:      0.0.1
# Release:      1
# License:      CC-BA (Creative Commons By Attrbution)
#               http://creativecommons.org/licenses/by/4.0/legalcode
# Group:        System
# Source:       N/A
# URL:          http://github.com/richardatlateralblast/faust
# Distribution: UNIX
# Vendor:       UNIX
# Packager:     Richard Spindler <richard@lateralblast.com.au>
# Description:  Imports hosts file into a JSON based config file for Shuttle SSH [1]
#               [1] https://fitztrev.github.io/shuttle/

# Required modules

require 'getopt/std'
require 'json'

options   = "hi:jo:T:tV"
home_dir = ENV['HOME']
terminal = "iTerm.app"
on_boot  = true

def get_version()
  file_array = IO.readlines $0
  version    = file_array.grep(/^# Version/)[0].split(":")[1].gsub(/^\s+/,'').chomp
  packager   = file_array.grep(/^# Packager/)[0].split(":")[1].gsub(/^\s+/,'').chomp
  name       = file_array.grep(/^# Name/)[0].split(":")[1].gsub(/^\s+/,'').chomp
  string     = name+" v. "+version+" "+packager
  return string
end

# Print the version of the script

def print_version()
  puts
  string = get_version()
  puts string
  puts
  return
end

# Print information regarding the usage of the script

def print_usage(options,on_boot,terminal)
  puts
  puts "Usage: "+$0+" -["+options+"]"
  puts
  puts "-V:\tDisplay version information"
  puts "-h:\tDisplay usage information"
  puts "-i:\tImport file"
  puts "-o:\tOutput file"
  puts "-j:\tConvert hosts file to a JSON file"
  puts "-t:\tOutput to standard IO"
  puts "-T:\tSet Terminal application (default #{terminal})"
  puts "-l:\tStart Shuttle at login (default #{on_boot})"
  puts
  return
end

def hosts_to_json(input_file,output_file,on_boot,terminal)
  if output_file.match(/[A-z]/)
    file = File.open(output_file,"w")
  end
  input   = IO.readlines(input_file)
  string  = get_version()
  domains = {}
  input.each do |line|
    line = line.chomp
    if !line.match(/^#|^127|^255|^f|^:/) and line.match(/[a-z]|[0-9]/)
      info      = {}
      user_name = ""
      if line.match(/#/)
        user_name = line.split(/#/)[1].gsub(/\s+/,"")
      end
      host_info   = line.split(/\s+/)
      ip_address  = host_info[0]
      full_name   = host_info[1]
      if full_name.match(/\./)
        domain_name = full_name.split(/\./)[1..-1].join(".")
        host_name   = full_name.split(/\./)[0]
      else
        domain_name = "local"
        host_name   = full_name
      end
      domain_name = domain_name.capitalize
      info["name"] = host_name
      if user_name.match(/[A-z]/)
        info["cmd"]  = "ssh "+user_name+"@"+host_name
      else
        info["cmd"]  = "ssh "+host_name
      end
      if !domains[domain_name]
        domains[domain_name] = []
      end
      domains[domain_name].push(info)
    end
  end
  json = {
    "_comment1"       => "Shuttle SSH JSON config file created by "+string,
    "terminal"        => terminal,
    "launch_at_login" => on_boot,
    "hosts"           => [ domains ],
  }
  output = JSON.pretty_generate(json)
  if !output_file.match(/[A-z]/)
    puts output
  else
    file.write(output)
    file.close()
  end
  return
end


begin
  opt  = Getopt::Std.getopts(options)
  used = 0
  options.gsub(/:/,"").each_char do |option|
    if opt[option]
      used = 1
    end
  end
  if used == 0
    print_usage(options,on_boot,terminal)
  end
rescue
  print_usage(options,on_boot,terminal)
  exit
end

if opt["h"]
  print_usage(options,on_boot,terminal)
  exit
end

if opt["V"]
  print_version()
  exit
end

if opt["i"]
  input_file = opt["i"]
else
  input_file = "/etc/hosts"
end

if !File.exist?(input_file)
  puts "File: "+input_file+" does not exist"
  exit
end

if opt["T"]
  terminal = opt["T"]
  if terminal.match(/\.app/)
    terminal = terminal+".app"
  end
  if !File.exist?("/Applications/#{terminal}") and !File.exist?("/Applications/Utilities/#{terminal}")
    puts "Terminal application "+terminal+" does not exist"
    exit
  end
  terminal = terminal.gsub(/\.app/,"")
else
  terminal = terminal.gsub(/\.app/,"")
end

if opt["l"]
  on_boot = opt["l"]
  if on_boot.match(/[N,n][O,o]/)
    on_boot = false
  else
    on_boot = true
  end
end


if opt["t"]
  output_file = ""
else
  if opt["o"]
    output_file = opt["o"]
  else
    output_file = home_dir+"/.shuttle.json"
  end
end

hosts_to_json(input_file,output_file,on_boot,terminal)


