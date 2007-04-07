
task :plugins do
  `rm -rf vendor/plugins/rspec`
  `ruby script/plugin install svn://rubyforge.org/var/svn/rspec/tags/REL_0_8_2/rspec_on_rails/vendor/plugins/rspec_on_rails`
end