require 'spec_helper'

describe Budik::Devices, '#initialize' do
  it 'correctly parses commands' do
    config = Budik::Config.instance
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

describe Budik::Devices, '#storage_parse_cmd' do
  it 'correctly parses commands' do
    devices = Budik::Devices.instance

    cmd = 'mount'
    template = 'udisksctl mount -b $partition'
    subst = { '$partition': '/dev/sda1' }
    devices.storage_parse_cmd(cmd, template, subst, mount: true)

    parsed_cmd = 'udisksctl mount -b /dev/sda1'
    expect(devices.storage[:mount_command]).to eq parsed_cmd
    expect(devices.storage[:mount]).to eq true
  end
end
