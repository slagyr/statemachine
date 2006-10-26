$:.unshift('lib')
require 'rubygems'
require 'rake/gempackagetask'
require 'rake/contrib/rubyforgepublisher'
require 'rake/clean'
require 'rake/rdoctask'
require 'spec/rake/spectask'
require 'statemachine'

# Some of the tasks are in separate files since they are also part of the website documentation
"load File.dirname(__FILE__) + '/tasks/examples.rake'
load File.dirname(__FILE__) + '/tasks/examples_specdoc.rake'
load File.dirname(__FILE__) + '/tasks/examples_with_rcov.rake'
load File.dirname(__FILE__) + '/tasks/failing_examples_with_html.rake'
load File.dirname(__FILE__) + '/tasks/verify_rcov.rake'"

PKG_NAME = "statemachine"
PKG_VERSION   = StateMachine::VERSION::STRING
PKG_TAG = StateMachine::VERSION::TAG
PKG_FILE_NAME = "#{PKG_NAME}-#{PKG_VERSION}"
PKG_FILES = FileList[
  '[A-Z]*',
  'lib/**/*.rb', 
  'spec/**/*.rb' 
#  'examples/**/*',
]

task :default => :spec

desc "Run all specs"
Spec::Rake::SpecTask.new do |t|
  t.spec_files = FileList['spec/**/*_spec.rb']
#  t.spec_opts = ['--diff','--color']
#  t.rcov = true
#  t.rcov_dir = 'doc/output/coverage'
#  t.rcov_opts = ['--exclude', 'spec\/spec,bin\/spec']"
end

#desc 'Generate HTML documentation for website'
#task :webgen do
#  Dir.chdir 'doc' do
#    output = nil
#    IO.popen('webgen 2>&1') do |io|
#      output = io.read
#    end
#    raise "ERROR while running webgen: #{output}" if output =~ /ERROR/n || $? != 0
#  end
#end

#desc 'Generate RDoc'
#rd = Rake::RDocTask.new do |rdoc|
#  rdoc.rdoc_dir = 'doc/output/rdoc'
#  rdoc.options << '--title' << 'RSpec' << '--line-numbers' << '--inline-source' << '--main' << 'README'
#  rdoc.rdoc_files.include('README', 'CHANGES', 'EXAMPLES.rd', 'lib/**/*.rb')
#end
#task :rdoc => :examples_specdoc # We generate EXAMPLES.rd

spec = Gem::Specification.new do |s|
  s.name = PKG_NAME
  s.version = PKG_VERSION
  s.summary = StateMachine::VERSION::DESCRIPTION
  s.description = <<-EOF
    StateMachine is a ruby library for building Finite State Machines (FSM), also known as Finite State Automata (FSA).
  EOF

  s.files = PKG_FILES.to_a
  s.require_path = 'lib'

#  s.has_rdoc = true
#  s.rdoc_options = rd.options
#  s.extra_rdoc_files = rd.rdoc_files.reject { |fn| fn =~ /\.rb$|^EXAMPLES.rd$/ }.to_a
  
  s.test_files = Dir.glob('spec/*_spec.rb')
  s.require_path = 'lib'
  s.autorequire = 'statemachine'
#  s.bindir = "bin"
#  s.executables = ["spec"]
#  s.default_executable = "spec"
  s.author = "Micah Martin"
  s.email = "statemachine-devel@rubyforge.org"
  s.homepage = "http://statemachine.rubyforge.org"
  s.rubyforge_project = "statemachine"
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.need_zip = true
  pkg.need_tar = true
end

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

task :clobber do
  rm_rf 'doc/output'
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


#desc "Build the website, but do not publish it"
#task :website => [:clobber, :verify_rcov, :webgen, :failing_examples_with_html, :spec, :examples_specdoc, :rdoc]

#desc "Upload Website to RubyForge"
#task :publish_website => [:verify_user, :website] do
#  publisher = Rake::SshDirPublisher.new(
#    "rspec-website@rubyforge.org",
#    "/var/www/gforge-projects/#{PKG_NAME}",
#    "doc/output"
#  )

#  publisher.upload
#end

task :verify_user do
  raise "RUBYFORGE_USER environment variable not set!" unless ENV['RUBYFORGE_USER']
end

task :verify_password do
  raise "RUBYFORGE_PASSWORD environment variable not set!" unless ENV['RUBYFORGE_PASSWORD']
end

desc "Publish gem+tgz+zip on RubyForge. You must make sure lib/version.rb is aligned with the CHANGELOG file"
task :publish_packages => [:verify_user, :verify_password, :package] do
  require 'meta_project'
  require 'rake/contrib/xforge'
  release_files = FileList[
    "pkg/#{PKG_FILE_NAME}.gem",
    "pkg/#{PKG_FILE_NAME}.tgz",
    "pkg/#{PKG_FILE_NAME}.zip"
  ]

  Rake::XForge::Release.new(MetaProject::Project::XForge::RubyForge.new(PKG_NAME)) do |xf|
    # Never hardcode user name and password in the Rakefile!
    xf.user_name = ENV['RUBYFORGE_USER']
    xf.password = ENV['RUBYFORGE_PASSWORD']
    xf.files = release_files.to_a
    xf.release_name = "statemachine #{PKG_VERSION}"
  end
end