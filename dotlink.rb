#!/usr/bin/env ruby
#
# dotlink Ruby version
#
# TODO
# - create a 'clobber' or 'refresh'  option to remove everything and start
#   over
# - clean up actual dotfiles
#   - .mutt needs moved to just mutt

require 'git'
require 'optparse'

home = "#{Dir.home}"
skel = [ '.bashrc', '.bash_profile' ]

options = {}

op = OptionParser.new do |opts|
  opts.banner = "Usage: dotlink.rb [options]"

  opts.on("-c","--clean", "Clean up old environment") do |c|
    options[:clean] = c
  end

  opts.on("-n","--new", "Create a new environment") do |n|
    options[:new] = n
  end
end

op.parse!

if options[:new] == nil
end

#
# Create a new environment
#
if options[:new]

  if File.directory?("#{home}/.dotfiles")
    puts "Dotfiles repo already present...Checking Symlinks"
  else
    Git.clone "git://github.com/jonmosco/dotfiles.git", "#{home}/.dotfiles"
  end

  # Check for existing dotfiles
  skel.each do |sk|
    if File.file?("#{home}/#{sk}")
      puts "Deleting #{sk}"
      File.delete("#{home}/#{sk}")
    end
  end

  puts "Creating Symlinks..."

  Dir.foreach("#{home}/.dotfiles") do |item|
    next if item == '.' or item == '..'
    if File.symlink?("#{home}/.#{item}")
      puts "Symlink for #{item} already exists"
    else
      File.symlink("#{home}/.dotfiles/#{item}", "#{home}/.#{item}")
    end
  end
end

#
# Clean up our old environment
# * WARNING * This is destructive
#
if options[:clean]
  Dir.foreach("#{home}/.dotfiles") do |item|
    next if item == '.' or item == '..'
    File.delete("#{home}/.#{item}")
  end
end
