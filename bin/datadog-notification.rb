#! /usr/bin/env ruby
#
#   datadog-notification
#
# DESCRIPTION:
#
# OUTPUT:
#   plain text
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
#   Copyright 2015 Sonian, Inc <support@sensuapp.net>
#   Released under the same terms as Sensu (the MIT license); see LICENSE
#   for details.
#

require 'sensu-handler'
require 'dogapi'

#
# Datadog notifications
#
class DatadogNotif < Sensu::Handler
  # filter disabled alerts and exit with an 'OK' status if it is
  # else handle the alert as needed
  #
  def handle
    filter
    datadog
  end

  # determine the action to take for the event
  def acquire_action
    case @event['action']
    when 'create'
      'error'
    when 'resolve'
      'success'
    end
  end

  # Return a low priotiry for resolve and warn events, normal for critical and unknown
  def acquire_priority
    case @event['status']
    when '0', '1'
      'low'
    when '2', '3'
      'normal'
    end
  end

  # filter disabled alerts and exit with an 'OK' status if it is
  def filter
    # #YELLOW
    if @event['check']['alert'] == false # rubocop:disable GuardClause
      puts 'alert disabled -- filtered event ' + [@event['client']['name'], @event['check']['name']].join(' : ')
      exit 0
    end
  end

  # submit the event to datadog
  def datadog
    description = @event['notification'] || [@event['client']['name'], @event['check']['name'], @event['check']['output']].join(' ')
    action = acquire_action
    priority = acquire_priority
    tags = []
    tags.push('sensu')
    # allow for tags to be set in the configuration, this could be used to indicate environment
    tags.concat(settings['datadog']['tags']) unless settings['datadog']['tags'].nil? && !settings['datadog']['tags'].kind_of(Array)
    # add the subscibers for the event to the tags
    tags.concat(@event['check']['subscribers']) unless @event['check']['subscribers'].nil?
    begin
      timeout(3) do
        dog = Dogapi::Client.new(settings['datadog']['api_key'], settings['datadog']['app_key'])
        response = dog.emit_event(Dogapi::Event.new(
                                    description,
                                    msg_title: @event['check']['name'],
                                    tags: tags,
                                    alert_type: action,
                                    priority: priority,
                                    source_type_name: settings['datadog']['source_type_name'] || 'sensu', # let the user set the source_type_name
                                    aggregation_key: @event['check']['name']
        ), host: @event['client']['name'])

        begin
          if response[0] == '202'
            puts 'Submitted event to Datadog'
          else
            puts "Unexpected response from Datadog: HTTP code #{response[0]}"
          end
        rescue
          puts "Could not determine whether sensu event was successfully submitted to Datadog: #{response}"
        end
      end
    rescue Timeout::Error
      puts 'Datadog timed out while attempting to ' + @event['action'] + ' a incident -- ' + incident_key
    end
  end
end
