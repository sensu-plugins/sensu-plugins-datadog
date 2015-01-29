#! /usr/bin/env ruby
#
#   datadog-metrics
#
# DESCRIPTION:
#
# OUTPUT:
#   metric data
#
# PLATFORMS:
#   Linux
#
# DEPENDENCIES:
#   gem: sensu-handler
#   gem: dogapi
#
# USAGE:
#
# NOTES:
#
# LICENSE:
#   Copyright 2013 Katherine Daniels (kd@gc.io)
#   Released under the same terms as Sensu (the MIT license); see LICENSE
#   for details.
#

require 'sensu-handler'
require 'dogapi'

#
# == Datadog Metrics
#
class DatadogMetrics < Sensu::Handler
  # Override filters from Sensu::Handler.
  # They are not appropriate for metric handlers
  #
  def filter
  end

  # Create a handle and event set
  #
  def handle
    @dog = Dogapi::Client.new(settings['datadog']['api_key'], settings['datadog']['app_key'])

    @event['check']['output'].split("\n").each do |line|
      name, value, timestamp = line.split(/\s+/)
      emit_metric(name, value, timestamp)
    end
  end

  # Push metric point
  #
  # === Attributes
  #
  # * +name+
  # * +value+
  # * +_timestamp+
  def emit_metric(name, value, _timestamp)
    timeout(3) do
      @dog.emit_point(name, value, host: @event['client']['name'])
    end
  # Raised when any metrics could not be sent
  #
  rescue Timeout::Error
    puts 'datadog -- timed out while sending metrics'
  rescue => error
    puts "datadog -- failed to send metrics: #{error.message}"
    puts " #{error.backtrace.join("\n\t")}"
  end
end
