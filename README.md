## Sensu-Plugins-Datadog

[ ![Codeship Status for sensu-plugins/sensu-plugins-datadog](https://codeship.com/projects/5e9844c0-b191-0132-e195-32bd639983ea/status?branch=master)](https://codeship.com/projects/69880)[![Gem Version](https://badge.fury.io/rb/sensu-plugins-datadog.svg)](http://badge.fury.io/rb/sensu-plugins-datadog)
[![Code Climate](https://codeclimate.com/github/sensu-plugins/sensu-plugins-datadog/badges/gpa.svg)](https://codeclimate.com/github/sensu-plugins/sensu-plugins-datadog)
[![Test Coverage](https://codeclimate.com/github/sensu-plugins/sensu-plugins-datadog/badges/coverage.svg)](https://codeclimate.com/github/sensu-plugins/sensu-plugins-datadog)
[![Dependency Status](https://gemnasium.com/sensu-plugins/sensu-plugins-datadog.svg)](https://gemnasium.com/sensu-plugins/sensu-plugins-datadog)

## Functionality
```json
{
  "datadog": {
    "api_key": "12345",
    "app_key": "54321",
    "tags": []
  }
}
```
## Files

**bin/datadog-metrics.rb**

Send metrics to datadog

**bin/datadog-notification.rb**

Send event data to datadog

## Usage

## Installation

Add the public key (if you haven’t already) as a trusted certificate

```
gem cert --add <(curl -Ls https://raw.githubusercontent.com/sensu-plugins/sensu-plugins.github.io/master/certs/sensu-plugins.pem)
gem install sensu-plugins-datadog -P MediumSecurity
```

You can also download the key from /certs/ within each repository.

#### Rubygems

`gem install sensu-plugins-datadog`

#### Bundler

Add *sensu-plugins-datadog* to your Gemfile and run `bundle install` or `bundle update`

#### Chef

Using the Sensu **sensu_gem** LWRP
```
sensu_gem 'sensu-plugins-datadog' do
  options('--prerelease')
  version '0.0.1.alpha.1'
end
```

Using the Chef **gem_package** resource
```
gem_package 'sensu-plugins-datadog' do
  options('--prerelease')
  version '0.0.1.alpha.1'
end
```

## Notes
