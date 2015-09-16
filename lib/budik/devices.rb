module Budik
  # 'Devices' class manages display and storage devices.
  class Devices
    include Singleton

    def initialize
      options = Config.instance.options
      @tv = {}
      @storage = { mounted: nil, awake: nil, unmount: false }

      tv_load(options['tv'])
      storage_load(options['sources']['download'])
    end

    attr_accessor :storage, :tv

    def storage_load(options)
      @storage[:device] = options['device']
      @storage[:partition] = options['partition']
      @storage[:dir] = options['dir']

      part_sub = { '$partition': @storage[:partition] }
      dev_sub = { '$device': @storage[:device] }

      storage_parse_cmd('mount', options['mount'], part_sub, mount: false)
      storage_parse_cmd('unmount', options['unmount'], part_sub, unmount: true)
      storage_parse_cmd('sleep', options['sleep'], dev_sub, awake: false)
    end

    def storage_parse_cmd(cmd, template, subst, state_mods = {})
      return if template.empty?

      cmd = (cmd + '_command').to_sym
      var, val = subst.first
      @storage[cmd] = template.gsub(var.to_s, val)
      state_mods.each { |state, setting| @storage[state] = setting }
    end

    def storage_mount
      unless @storage[:mounted].nil? || @storage[:mounted] == true
        system(@storage[:mount_command])
      end

      @storage[:mounted] = true unless @storage[:mounted].nil?
      @storage[:awake] = true unless @storage[:awake].nil?
    end

    def storage_unmount
      unmount = !@storage[:unmount]
      unless unmount || @storage[:mounted].nil? || @storage[:mounted] == false
        system(@storage[:unmount_command])
      end

      @storage[:mounted] = false unless @storage[:mounted].nil?
    end

    def storage_sleep
      sleep_check = @storage[:awake].nil? || @storage[:awake] == false

      unless sleep_check || @storage[:mounted] == true
        system(@storage[:sleep_command])
      end

      @storage[:awake] = false unless @storage[:awake].nil?
    end

    def tv_load(options)
      if options['available']
        @tv[:use_if_no_video] = options['use_if_no_video']
        @tv[:wait_secs_after_on] = options['wait_secs_after_on']
        @tv[:on] = false
      else
        @tv[:on] = nil
      end
    end

    def tv_on
      unless @tv[:on].nil? || @tv[:on] == true
        system('echo "on 0" | cec-client -s')
        sleep(@tv[:wait_secs_after_on]) unless @tv[:wait_secs_after_on].nil?
        system('echo "as" | cec-client -s')
      end

      @tv[:on] = true unless @tv[:on].nil?
    end

    def tv_off
      # Doesn't work on my TV
      unless @tv[:on].nil? || @tv[:on] == false
        system('echo "standby 0" | cec-client -s')
      end

      @tv[:on] = false unless @tv[:on].nil?
    end
  end
end
