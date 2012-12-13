$:.unshift('lib')
require 'rubygems'
require 'rake/gempackagetask'
require 'rake/clean'
require 'rake/rdoctask'
require 'rspec/core/rake_task'
require 'statemachine'
require "bundler/gem_tasks"

PKG_NAME = "statemachine"
PKG_VERSION   = Statemachine::VERSION::STRING
PKG_TAG = Statemachine::VERSION::TAG
PKG_FILE_NAME = "#{PKG_NAME}-#{PKG_VERSION}"
PKG_FILES = FileList[
  '[A-Z]*',
  'lib/**/*.rb', 
  'spec/**/*.rb' 
]

task :default => :spec

RSpec::Core::RakeTask.new(:spec)


WEB_ROOT = File.expand_path('~/Projects/slagyr.github.com/statemachine/')

desc 'Generate RDoc'
rd = Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_dir = "#{WEB_ROOT}/rdoc"
  rdoc.options << '--title' << 'Statemachine' << '--line-numbers' << '--inline-source' << '--main' << 'README.rdoc'
  rdoc.rdoc_files.include('README.rdoc', 'CHANGES', 'lib/**/*.rb')
end
task :rdoc

def egrep(pattern)
  Dir['**/*.rb'].each do |fn|
    count = 0
    open(fn) do |f|
      while line = f.gets
        count += 1
        if line =~ pattern
          puts "#{fn}:#{count}:#{line}"
        end
      end
    end
  end
end

desc "Look for TODO and FIXME tags in the code"
task :todo do
  egrep /(FIXME|TODO|TBD)/
end

task :release => [:clobber, :verify_committed, :verify_user, :verify_password, :spec, :publish_packages, :tag, :publish_website, :publish_news]

desc "Verifies that there is no uncommitted code"
task :verify_committed do
  IO.popen('svn stat') do |io|
    io.each_line do |line|
      raise "\n!!! Do a svn commit first !!!\n\n" if line =~ /^\s*M\s*/
    end
  end
end

desc "Creates a tag in svn"
task :tag do
  puts "Creating tag in SVN"
  `svn cp svn+ssh://#{ENV['RUBYFORGE_USER']}@rubyforge.org/var/svn/statemachine/trunk svn+ssh://#{ENV['RUBYFORGE_USER']}@rubyforge.org/var/svn/statemachine/tags/#{PKG_VERSION} -m "Tag release #{PKG_TAG}"`
  puts "Done!"
end

desc 'Generate HTML documentation for website'
task :webgen do
  system "rm -rf doc/website/out"
  system "rm -rf doc/website/webgen.cache"
  system "cd doc/website; webgen -v render; cp -rf out/* #{WEB_ROOT}"
end

desc "Build the website, but do not publish it"
task :website => [:webgen, :rdoc]

task :verify_user do
  raise "RUBYFORGE_USER environment variable not set!" unless ENV['RUBYFORGE_USER']
end

task :verify_password do
  raise "RUBYFORGE_PASSWORD environment variable not set!" unless ENV['RUBYFORGE_PASSWORD']
end