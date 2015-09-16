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
    expect(devices.storage[:mount]).to be true
  end
end

describe Budik::Devices, '#storage_mount' do
  context 'if not mounted' do
    it 'calls mount command' do
      devices = Budik::Devices.instance
      devices.storage[:mounted] = false
      mount_command = 'udisksctl mount -b /dev/sda1'

      expect(devices).to receive(:system).with(mount_command)
      devices.storage_mount
      expect(devices.storage[:mounted]).to be true
    end
  end

  context 'if already mounted' do
    it "doesn't do anything" do
      devices = Budik::Devices.instance
      devices.storage[:mounted] = true
      mount_command = 'udisksctl mount -b /dev/sda1'

      expect(devices).not_to receive(:system).with(mount_command)
      devices.storage_mount
      expect(devices.storage[:mounted]).to be true
    end
  end

  context 'if mount is disabled' do
    it "doesn't do anything" do
      devices = Budik::Devices.instance
      devices.storage[:mounted] = nil
      mount_command = 'udisksctl mount -b /dev/sda1'

      expect(devices).not_to receive(:system).with(mount_command)
      devices.storage_mount
      expect(devices.storage[:mounted]).to be_nil
    end
  end
end

describe Budik::Devices, '#storage_unmount' do
  context 'if mounted' do
    it 'calls unmount command' do
      devices = Budik::Devices.instance
      devices.storage[:unmount] = true
      devices.storage[:mounted] = true
      unmount_command = 'udisksctl unmount -b /dev/sda1'

      expect(devices).to receive(:system).with(unmount_command)
      devices.storage_unmount
      expect(devices.storage[:mounted]).to be false
    end
  end

  context 'if not mounted' do
    it "doesn't do anything" do
      devices = Budik::Devices.instance
      devices.storage[:unmount] = true
      devices.storage[:mounted] = false
      unmount_command = 'udisksctl unmount -b /dev/sda1'

      expect(devices).not_to receive(:system).with(unmount_command)
      devices.storage_unmount
      expect(devices.storage[:mounted]).to be false
    end
  end

  context 'if unmount is disabled' do
    it "doesn't do anything" do
      devices = Budik::Devices.instance
      devices.storage[:unmount] = false
      unmount_command = 'udisksctl unmount -b /dev/sda1'

      expect(devices).not_to receive(:system).with(unmount_command)
      devices.storage_unmount
    end
  end
end

describe Budik::Devices, '#storage_sleep' do
  context 'if awake' do
    it 'calls sleep command' do
      devices = Budik::Devices.instance
      devices.storage[:awake] = true
      sleep_command = 'sudo hdparm -y /dev/sda'

      expect(devices).to receive(:system).with(sleep_command)
      devices.storage_sleep
      expect(devices.storage[:awake]).to be false
    end
  end

  context 'if already asleep' do
    it "doesn't do anything" do
      devices = Budik::Devices.instance
      devices.storage[:awake] = false
      sleep_command = 'sudo hdparm -y /dev/sda'

      expect(devices).not_to receive(:system).with(sleep_command)
      devices.storage_sleep
      expect(devices.storage[:awake]).to be false
    end
  end

  context 'if sleep is disabled' do
    it "doesn't do anything" do
      devices = Budik::Devices.instance
      devices.storage[:awake] = nil
      sleep_command = 'sudo hdparm -y /dev/sda'

      expect(devices).not_to receive(:system).with(sleep_command)
      devices.storage_sleep
      expect(devices.storage[:awake]).to be_nil
    end
  end
end

describe Budik::Devices, '#tv_on' do
  context 'if TV is off' do
    it 'turns it on' do
      devices = Budik::Devices.instance
      devices.tv[:on] = false
      devices.tv[:wait_secs_after_on] = 0
      tv_on_command = 'echo "on 0" | cec-client -s'
      tv_as_command = 'echo "as" | cec-client -s'

      expect(devices).to receive(:system).with(tv_on_command)
      expect(devices).to receive(:system).with(tv_as_command)
      devices.tv_on
      expect(devices.tv[:on]).to be true
    end
  end

  context 'if TV is on' do
    it "doesn't do anything" do
      devices = Budik::Devices.instance
      devices.tv[:on] = true
      devices.tv[:wait_secs_after_on] = 0
      tv_on_command = 'echo "on 0" | cec-client -s'
      tv_as_command = 'echo "as" | cec-client -s'

      expect(devices).not_to receive(:system).with(tv_on_command)
      expect(devices).not_to receive(:system).with(tv_as_command)
      devices.tv_on
      expect(devices.tv[:on]).to be true
    end
  end

  context 'if TV is not available' do
    it "doesn't do anything" do
      devices = Budik::Devices.instance
      devices.tv[:on] = nil
      devices.tv[:wait_secs_after_on] = 0
      tv_on_command = 'echo "on 0" | cec-client -s'
      tv_as_command = 'echo "as" | cec-client -s'

      expect(devices).not_to receive(:system).with(tv_on_command)
      expect(devices).not_to receive(:system).with(tv_as_command)
      devices.tv_on
      expect(devices.tv[:on]).to be nil
    end
  end
end

describe Budik::Devices, '#tv_off' do
  context 'if TV is on' do
    it 'turns it off' do
      devices = Budik::Devices.instance
      devices.tv[:on] = true
      tv_off_command = 'echo "standby 0" | cec-client -s'

      expect(devices).to receive(:system).with(tv_off_command)
      devices.tv_off
      expect(devices.tv[:on]).to be false
    end
  end

  context 'if TV is off' do
    it "doesn't do anything" do
      devices = Budik::Devices.instance
      devices.tv[:on] = false
      tv_off_command = 'echo "standby 0" | cec-client -s'

      expect(devices).not_to receive(:system).with(tv_off_command)
      devices.tv_off
      expect(devices.tv[:on]).to be false
    end
  end

  context 'if TV is not available' do
    it "doesn't do anything" do
      devices = Budik::Devices.instance
      devices.tv[:on] = nil
      tv_off_command = 'echo "standby 0" | cec-client -s'

      expect(devices).not_to receive(:system).with(tv_off_command)
      devices.tv_off
      expect(devices.tv[:on]).to be nil
    end
  end
end
