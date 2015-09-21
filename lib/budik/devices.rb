# = devices.rb
# This file contains methods for managing devices (storage and TV).
#
# == Contact
#
# Author::  Petr Schmied (mailto:jblack@paworld.eu)
# Website:: http://www.paworld.eu
# Date::    September 20, 2015

module Budik
  # 'Devices' class manages display and storage devices.
  class Devices
    include Singleton

    # Loads TV and storage settings.
    def initialize
      options = Config.instance.options
      @tv = {}
      @storage = { mounted: nil, awake: nil, unmount: false }

      tv_load(options['tv'])
      storage_load(options['sources']['download'])
    end

    # Returns TV and storage settings.
    attr_accessor :storage, :tv

    # Loads storage settings.
    #
    # - *Args*:
    #   - +options+ -> Storage options (Hash).
    #
    def storage_load(options)
      @storage[:device] = options['device']
      @storage[:partition] = options['partition']
      @storage[:dir] = options['dir']

      part_sub = { '$partition': @storage[:partition] }
      dev_sub = { '$device': @storage[:device] }

      storage_parse_cmd('mount', options['mount'], part_sub, mounted: false)
      storage_parse_cmd('unmount', options['unmount'], part_sub, unmount: true)
      storage_parse_cmd('sleep', options['sleep'], dev_sub, awake: false)
    end

    # Substitutes device and partition in (un)mount and sleep commands.
    #
    # == Example
    #
    # cmd = 'sleep'
    # template = 'sudo hdparm -y $device'
    # subst = { '$device': '/dev/sda' }
    # state_mods = { awake: false }
    #
    # Parsed command: 'sudo hdparm -y /dev/sda'
    # State 'awake' set to false
    #
    # - *Args*:
    #   - +cmd+ -> Command ('mount', 'unmount' or 'sleep').
    #   - +template+ -> Command template (String).
    #   - +subst+ -> Variable to substitute (Hash, variable: value).
    #   - +state_mods+ -> State modifiers (Hash).
    #
    def storage_parse_cmd(cmd, template, subst, state_mods = {})
      return if template.empty?

      cmd = (cmd + '_command').to_sym
      var, val = subst.first
      @storage[cmd] = template.gsub(var.to_s, val)
      state_mods.each { |state, setting| @storage[state] = setting }
    end

    # Mounts partition if needed and if not already mounted
    # If applicable, sets 'mounted' and 'awake' states to true
    def storage_mount
      unless @storage[:mounted].nil? || @storage[:mounted] == true
        system(@storage[:mount_command])
      end

      @storage[:mounted] = true unless @storage[:mounted].nil?
      @storage[:awake] = true unless @storage[:awake].nil?
    end

    # Unmounts partition if needed and if mounted
    # If applicable, sets 'mounted' state to false
    def storage_unmount
      unmount = !@storage[:unmount]
      unless unmount || @storage[:mounted].nil? || @storage[:mounted] == false
        system(@storage[:unmount_command])
      end

      @storage[:mounted] = false unless @storage[:mounted].nil?
    end

    # Spins device down if needed and if awake
    # If applicable, sets 'awake' state to false
    def storage_sleep
      sleep_check = @storage[:awake].nil? || @storage[:awake] == false

      unless sleep_check || @storage[:mounted] == true
        system(@storage[:sleep_command])
      end

      @storage[:awake] = false unless @storage[:awake].nil?
    end

    # Loads TV settings if TV is available.
    #
    # - *Args*:
    #   - +options+ -> TV options (Hash).
    #
    def tv_load(options)
      if options['available']
        @tv[:use_if_no_video] = options['use_if_no_video']
        @tv[:wait_secs_after_on] = options['wait_secs_after_on']
        @tv[:on] = false
      else
        @tv[:on] = nil
      end
    end

    # Turns on TV if needed and if not already on
    # Gives TV time to turn on, then sets active HDMI as active source
    # If applicable, sets 'on' state to true
    def tv_on
      unless @tv[:on].nil? || @tv[:on] == true
        system('echo "on 0" | cec-client -s >/dev/null')
        sleep(@tv[:wait_secs_after_on]) unless @tv[:wait_secs_after_on].nil?
        system('echo "as" | cec-client -s >/dev/null')
      end

      @tv[:on] = true unless @tv[:on].nil?
    end

    # Turns off TV if needed and if on
    # If applicable, sets 'on' state to false
    # Doesn't work on my TV
    def tv_off
      unless @tv[:on].nil? || @tv[:on] == false
        system('echo "standby 0" | cec-client -s >/dev/null')
      end

      @tv[:on] = false unless @tv[:on].nil?
    end
  end
end
