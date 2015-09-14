module Budik
  class Devices
    include Singleton

    def initialize
      options = Config.instance.options

      tv_options = options['tv']
      @tv = Hash.new
      if tv_options['available']
        @tv[:use_if_no_video] = tv_options['use_if_no_video']
        @tv[:wait_secs_after_on] = tv_options['wait_secs_after_on']
        @tv[:on] = false
      else
        @tv[:on] = nil
      end

      storage_options = options['sources']['download']
      @storage = { mounted: nil, awake: nil, unmount: false }
      @storage[:device] = storage_options['device']
      @storage[:partition] = storage_options['partition']
      @storage[:dir] = storage_options['dir']

      unless storage_options['mount'].empty?
        @storage[:mount_command] = storage_options['mount']
        @storage[:mount_command].gsub!('$partition', @storage[:partition])
        @storage[:mounted] = false
      end
      unless storage_options['unmount'].empty?
        @storage[:unmount_command] = storage_options['unmount']
        @storage[:unmount_command].gsub!('$partition', @storage[:partition])
        @storage[:unmount] = true
      end
      unless storage_options['sleep'].empty?
        @storage[:sleep_command] = storage_options['sleep']
        @storage[:sleep_command].gsub!('$device', @storage[:device])
        @storage[:awake] = false
      end
    end

    attr_reader :storage
    attr_reader :tv

    def storage_mount
      unless @storage[:mounted] == nil || @storage[:mounted] == true
        system(@storage[:mount_command])
      end

      @storage[:mounted] = true
      @storage[:awake] = true
    end

    def storage_unmount
      unless @storage[:mounted] == nil || @storage[:mounted] == false
        system(@storage[:unmount_command])
      end

      @storage[:mounted] = false
    end

    def storage_sleep
      sleep_check = @storage[:awake] == nil || @storage[:awake] == false

      unless sleep_check || @storage[:mounted] == true
        system(@storage[:sleep_command])
      end

      @storage[:awake] = false
    end

    def tv_on
      unless @tv[:on] == nil || @tv[:on] == true
        system('echo "on 0" | cec-client -s')
        sleep(@tv[:wait_secs_after_on]) unless @tv[:wait_secs_after_on] == nil
        system('echo "as" | cec-client -s')
      end
      @tv[:on] = true
    end

    def tv_off
      # Doesn't work on my TV
      unless @tv[:on] == nil || @tv[:on] == false
        system('echo "standby 0" | cec-client -s')
      end

      @tv[:on] = false
    end
  end
end
