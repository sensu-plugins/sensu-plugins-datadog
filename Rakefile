
desc 'Generate documentation'
task :rdoc do
  `rm -rf doc/`
  `rdoc`
end

desc 'Don\'t run Rubocop for unsupported versions'
begin
  if RUBY_VERSION >= '2.0.0'
    args = [:spec, :make_bin_executable, :rubocop, :rdoc]
  else
    args = [:spec, :make_bin_executable, :rdoc]
  end
end

RuboCop::RakeTask.new

RSpec::Core::RakeTask.new(:spec) do |r|
  r.pattern = FileList['**/**/*_spec.rb']
end

# desc 'Calculate technical debt'
# task :calculate_debt do
#   `/usr/bin/env ruby scripts/tech_debt.rb`
# end

desc 'Make all plugins executable'
task :make_bin_executable do
  `chmod -R +x /bin/*`
end

task default: args
