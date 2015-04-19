#! /usr/bin/env ruby

plugin = File.basename(File.expand_path('.'))
spec = Gem::Specification.load("#{ plugin }.gemspec")
lib = File.expand_path('../lib')
version_file = "lib/#{ plugin }/version.rb"

$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require_relative "../../#{ plugin }/lib/#{ plugin }"
require 'github_api'
require 'date'

#
# Build a gem and deploy it to rubygems
#
def deploy_rubygems
  `gem build #{ plugin }.gemspec`
  `curl --data-binary #{ spec.full_name }.gem \
        -H $RG_API \
        https://rubygems.org/api/v1/gems`
end

def create_github_release(spec, plugin)
  @github = Github.new do |c|
    c.oauth_token = ENV['GITHUB_TOKEN']
  end
  @github.repos.releases.create 'sensu-plugins', plugin, spec.version,
                                tag_name: spec.version,
                                target_commitish: ENV['CI_COMMIT_ID'],
                                name: spec.version,
                                body: ENV['description'],
                                draft: spec.metadata['release_draft'],
                                prerelease: spec.metadata['release_prerelease']
end

def version_bump(version_file)
  # Read the file, bump the PATCH version
  contents = File.read(version_file).gsub(/(PATCH = )(\d+)/) { |_| Regexp.last_match[1] + (Regexp.last_match[2].to_i + 1).to_s }

  # Write the new contents of the file
  File.open(version_file, 'w') { |file| file.puts contents }
end

def create_commit(plugin)
  @github = Github.new do |c|
    c.oauth_token = ENV['GITHUB_TOKEN']
  end
  @github.git_data.commits.create 'sensu-plugins', plugin,
        message: "bump version",
        author: {
          name: ENV['CI_COMMITTER_USERNAME'],
          email: ENV['CI_COMMITTER_EMAIL'],
          date: Date.today.to_s
        }
end
deploy_rubygems if ENV['CI_MESSAGE'] == 'deploy bump'
create_github_release(spec, plugin) if ENV['CI_MESSAGE'] == 'deploy bump'
# version_bump(version)
# create_commit(plugin)
