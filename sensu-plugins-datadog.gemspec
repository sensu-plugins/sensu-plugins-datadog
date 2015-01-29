lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'date'

if RUBY_VERSION < '2.0.0'
  require 'sensu-plugins-datadog'
else
  require_relative 'lib/sensu-plugins-datadog'
end

pvt_key = '~/.ssh/gem-private_key.pem'

Gem::Specification.new do |s|
  s.name             = 'sensu-plugins-datadog'
  s.version          = SensuPluginsDatadog::VERSION
  s.authors          = ['Sonian, Inc. and contributors']
  s.email            = '<sensu-users@googlegroups.com>'
  s.homepage         = 'https://github.com/sensu-plugins/sensu-plugins-datadog'
  s.summary          = 'Datadog handlers Sensu'
  s.description      = 'Datadog handlers Sensu'
  s.license          = 'MIT'
  s.date             = Date.today.to_s
  s.files            = `git ls-files -z`.split("\x0")
  s.executables      = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.test_files       = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths    = ['lib']
  s.cert_chain       = ['certs/sensu-plugins.pem']
  s.signing_key      = File.expand_path(pvt_key) if $PROGRAM_NAME =~ /gem\z/

  s.add_runtime_dependency 'datadog',           '0.1.0.alpha'
  s.add_runtime_dependency 'sensu-plugin',      '1.1.0'

  s.add_development_dependency 'rubocop',       '~> 0.17.0'
  s.add_development_dependency 'rspec',         '~> 3.1'
  s.add_development_dependency 'bundler',       '~> 1.7'
  s.add_development_dependency 'rake',          '~> 10.0'
end
