## Sensu-Plugins-Datadog

[![Build Status](https://travis-ci.org/sensu-plugins/sensu-plugins-datadog.svg?branch=master)](https://travis-ci.org/sensu-plugins/sensu-plugins-datadog)
[![Gem Version](https://badge.fury.io/rb/sensu-plugins-datadog.svg)](http://badge.fury.io/rb/sensu-plugins-datadog)
[![Code Climate](https://codeclimate.com/github/sensu-plugins/sensu-plugins-datadog/badges/gpa.svg)](https://codeclimate.com/github/sensu-plugins/sensu-plugins-datadog)
[![Test Coverage](https://codeclimate.com/github/sensu-plugins/sensu-plugins-datadog/badges/coverage.svg)](https://codeclimate.com/github/sensu-plugins/sensu-plugins-datadog)

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

## Installation

Add the public key (if you haven’t already) as a trusted certificate

```
gem cert --add <(curl -Ls https://raw.githubusercontent.com/sensu-plugins/sensu-plugins.github.io/master/certs/sensu-plugins.pem)
gem install <gem> -P MediumSecurity
```

You can also download the key from /certs/ within each repository.

`gem install sensu-plugins-datadog`

Add *sensu-plugins-datadog* to your Gemfile, manifest, cookbook, etc

## Notes
