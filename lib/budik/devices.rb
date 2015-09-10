module Budik
  class Devices
    include Singleton

    def initialize
      # TODO: Options

      @storage_device = nil
      @storage_partition = nil
      @storage_awake = nil
      @storage_mounted = nil
      @storage_dir = nil

      @tv_on = nil
      @tv_sleep_after_on = nil
    end
  end
end
