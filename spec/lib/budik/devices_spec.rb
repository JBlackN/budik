require 'spec_helper'

describe Budik::Devices, '#initialize' do
  it 'correctly parses commands' do
    config = Budik::Config.instance
    config.load(Hash.new)
    storage_options = config.options['sources']['download']
    storage_options['device'] = '/dev/sda'
    storage_options['partition'] = '/dev/sda1'
    storage_options['mount'] = 'udisksctl mount -b $partition'
    storage_options['unmount'] = 'udisksctl unmount -b $partition'
    storage_options['sleep'] = 'sudo hdparm -y $device'

    devices = Budik::Devices.instance
    mount_command = 'udisksctl mount -b /dev/sda1'
    unmount_command = 'udisksctl unmount -b /dev/sda1'
    sleep_command = 'sudo hdparm -y /dev/sda'

    expect(devices.storage[:mount_command]).to eq mount_command
    expect(devices.storage[:unmount_command]).to eq unmount_command
    expect(devices.storage[:sleep_command]).to eq sleep_command
  end
end
