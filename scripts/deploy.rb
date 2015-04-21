#! /usr/bin/env ruby

plugin = File.basename(File.expand_path('.'))
spec = Gem::Specification.load("#{ plugin }.gemspec")
lib = File.expand_path('../lib')
# version_file = "lib/#{ plugin }/version.rb"

$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require_relative "../../#{ plugin }/lib/#{ plugin }"
require 'date'
require 'json'
require 'base64'

#
# Build a gem and deploy it to rubygems
#
def deploy_rubygems
  `gem build #{ plugin }.gemspec`
  `curl --data-binary #{ spec.full_name }.gem \
        -H $RG_API \
        https://rubygems.org/api/v1/gems`
end

#
# Create Github tag and release
#
def create_github_release(spec, plugin)
  `curl -H "Authorization: token #{ ENV['GITHUB_TOKEN'] }" -d '{ "tag_name": "#{ spec.version }", "target_commitish": "#{ ENV['CI_COMMIT_ID'] }", "name": "#{ spec.version }", "body": "#{ ENV['CI_MESSAGE'] }", "draft": "#{ spec.metadata['release_draft']}", "prerelease": "#{ spec.metadata['release_prerelease']}" }' https://api.github.com/repos/sensu-plugins/#{ plugin }/releases` # rubocop:disable all
end

#
# Bump the patch version of the plugin
#
def version_bump(version_file)
  # Read the file, bump the PATCH version
  contents = File.read(version_file).gsub(/(PATCH = )(\d+)/) { |_| Regexp.last_match[1] + (Regexp.last_match[2].to_i + 1).to_s }

  # Write the new contents of the file
  File.open(version_file, 'w') { |file| file.puts contents }
end

def encode_file
  file = 'lib/sensu-plugins-datadog/version.rb'
  Base64.strict_encode64(open(file) { |io| io.read })
end

#
# If the commit message == 'deploy bump' then doing the following
# If the commit message is anything else we just run tests
#
if ENV['CI_MESSAGE'] == 'deploy bump'
  # version_bump(version_file)
  deploy_rubygems
  create_github_release(spec, plugin)
end
