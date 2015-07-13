class Devices
    @@storage_device = nil
    @@storage_partition = nil
    @@storage_mounted = nil
    @@storage_dir = nil
    @@storage_awake = nil
    @@tv_on = nil
    @@tv_sleep_after_on = nil

    @@storage_set = false
    @@tv_set = false

    def self.storage_get(download_options)
        unless @@storage_set
            device = download_options["device"]
            partition = download_options["partition"]
            dir = download_options["dir"]
            mountable = download_options["mount"]
            can_sleep = download_options["sleep"]
            @@storage_device = device
            @@storge_partition = partition
            @@storage_dir = dir
            @@storage_mounted = false if mountable
            @@storage_awake = false if can_sleep
            @@storage_set = true
        end
    end

    def self.storage_mount
        system("udisksctl mount -b " + @@storage_partition) unless @@storage_mounted == nil || @@storage_mounted == true
        @@storage_mounted = true
        @@storage_awake = true
    end

    def self.storage_unmount
        system("udisksctl unmount -b " + @@storage_partition) unless @@storage_mounted == nil || @@storage_mounted == false
        @@storage_mounted = false
    end

    def self.storage_sleep
        system("sudo hdparm -y " + @@storage_device) unless @@storage_awake == nil || @@storage_awake == false || @@storage_mounted == true
        @@storage_awake == false
    end

    def self.storage_status
        status = Hash.new
        status["mount"] = @@storage_mounted
        status["sleep"] = !@@storage_awake
        return status
    end

    def self.tv_get(tv_options)
        unless @@tv_set
            @@tv_on = false if tv_options["available"]
            @@tv_sleep_after_on = tv_options["waitSecsAfterOn"]
            @@tv_set = true
        end
    end

    def self.tv_on
        system("echo \"on 0\" | cec-client -s") unless @@tv_on == nil || @tv_on == true
        sleep(@@tv_sleep_after_on) unless @@tv_sleep_after_on == nil
        @@tv_on = true
        system("echo \"as\" | cec-client -s")
    end

    def self.tv_off
        # Doesn't work on my TV
        system("echo \"standby 0\" | cec-client -s") unless @@tv_on == nil || @@tv_on == false
        @@tv_on = false
    end

    def self.tv_status
        @@tv_on ? "on" : "off"
    end
end
