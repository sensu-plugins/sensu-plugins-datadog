#! /usr/bin/env ruby

plugin = File.basename(File.expand_path('.'))
spec = Gem::Specification.load("#{ plugin }.gemspec")
lib = File.expand_path('../lib')
version_file = "lib/#{ plugin }/version.rb"

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
  `curl -i -H "Authorization: token #{ ENV['GITHUB_TOKEN'] }" -d '{ "tag_name": "#{ spec.version }", "target_commitish": "#{ ENV['CI_COMMIT_ID'] }", "name": "#{ spec.version }", "body": "#{ ENV['CI_MESSAGE'] }", "draft": "#{ spec.metadata['release_draft']}", "prerelease": "#{ spec.metadata['release_prerelease']}" }' https://api.github.com/repos/sensu-plugins/#{ plugin }/releases` # rubocop:disable all
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

def acquire_latest_commit
  head = JSON.parse(`curl -H "Authorization: token $GIT_TOKEN" https://api.github.com/repos/sensu-plugins/sensu-plugins-datadog/git/refs/heads/master`)

  # head_sha = head['object']['sha']
  # head_url = head['object']['url']

  head_commit = JSON.parse(`curl -H "Authorization: token $GIT_TOKEN" #{ head['object']['url'] }`)

  # head_commit_sha = head_commit['sha']
  # head_tree_sha   = head_commit['tree']['sha']
  # head_tree_url   = head_commit['tree']['url']

  [head_commit['tree']['url'], head_commit['tree']['sha'], head['object']['sha'], head_commit['sha']]
end

def encode_file
  file = 'lib/sensu-plugins-datadog/version.rb'
  Base64.strict_encode64(open(file) { |io| io.read })
end

def send_file_to_github
  file_data = JSON.parse(`curl -i -H "Authorization: token $GIT_TOKEN" -d '{"content": "#{ encode_file }", "encoding": "base64"}' https://api.github.com/repos/sensu-plugins/sensu-plugins-datadog/git/blobs`)# rubocop:disable all
  file_data['sha']
end

def commit_tree(head_tree_url, head_tree_sha, file_data_sha)
  data = JSON.parse(`curl -H "Authorization: token $GIT_TOKEN" #{ head_tree_url }`)

  `curl -i -H "Authorization: token $GIT_TOKEN" -d '{ "base_tree": "#{ head_tree_sha }", "tree": [ { "path": "lib/sensu-plugins-datadog/version.rb", "mode": "100644", "type": "blob", "sha": "#{ file_data_sha }" } ]}' https://api.github.com/repos/sensu-plugins/sensu-plugins-datadog/git/trees`# rubocop:disable all
  data['sha']
end

def create_commit(head_commit_sha, commit_tree_sha)
  commit_data = JSON.parse(`curl -i -H "Authorization: token $GIT_TOKEN" -d '{"message": "version bump", "parents": ["#{ head_commit_sha }"], "tree": "#{ commit_tree_sha }"}' https://api.github.com/repos/sensu-plugins/sensu-plugins-datadog/git/commits`)# rubocop:disable all

  `curl -i -H "Authorization: token $GIT_TOKEN" -d '{ "sha": "#{ commit_data['sha'] }", "force": true}' https://api.github.com/repos/sensu-plugins/sensu-plugins-datadog/git/refs/heads/master`# rubocop:disable all
end

#
# Commit the ner version back in Github (not functioning)
#
def create_github_commit(_plugin)
  head_tree_url, head_tree_sha, _head_sha, head_commit_sha = acquire_latest_commit
  file_sha = send_file_to_github
  commit_tree_sha = commit_tree(head_tree_url, head_tree_sha, file_sha)
  create_commit(head_commit_sha, commit_tree_sha)
end

#
# If the commit message == 'deploy bump' then doing the following
# If the commit message is anything else we just run tests
#
if ENV['CI_MESSAGE'] == 'deploy bump'
  version_bump(version_file)
  create_github_commit(plugin)
  deploy_rubygems
  create_github_release(spec, plugin)
end
