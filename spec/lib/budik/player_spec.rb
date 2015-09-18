require 'spec_helper'

options = Budik::Config.instance.options['player']
player = Budik::Player.instance

describe Budik::Player, '#omxplayer' do
  it 'plays a source using omxplayer' do
    player.player = 'omxplayer'
    player.player_options = options['omxplayer']
    player.player_options['volume_step_secs'] = 0
    cmd1 = player.omx_build_command('path1')
    cmd2 = player.omx_build_command('path2')

    i = o = e = t = double
    expect(Open3).to receive(:popen3).with(cmd1).and_yield(i, o, e, t).ordered
    expect(player).to receive(:omx_volume_control).with(i).ordered
    expect(Open3).to receive(:popen3).with(cmd2).and_yield(i, o, e, t).ordered
    expect(player).not_to receive(:omx_volume_control).with(i).ordered

    player.omxplayer(path: %w(path1 path2))
  end
end

describe Budik::Player, '#omx_build_command' do
  it 'correctly builds omxplayer command' do
    options['player'] = 'omxplayer'
    omx_options = player.player_options
    omx_options['path'] = 'omxplayer'
    omx_options['default_volume'] = -2100
    item = '/tmp/test.mp4'

    cmd = 'omxplayer --vol -2100 /tmp/test.mp4'
    expect(player.omx_build_command(item)).to eq cmd
  end
end

describe Budik::Player, '#omx_volume_control' do
  it 'incrementally increases volume' do
    i = double(puts: nil, close: nil)
    expect(i).to receive(:puts).exactly(7).times.ordered
    expect(i).to receive(:close).ordered
    player.omx_volume_control(i)
  end
end

describe Budik::Player, '#vlc' do
  it 'plays a source using vlc' do
    player.player = 'vlc'
    player.player_options = options['vlc']
    player.player_options['wait_secs_after_run'] = 0

    source = { path: %w(path1 path2) }
    cmd = player.vlc_build_command(source)

    expect(player).to receive(:spawn).with(cmd)
    allow(player).to receive(:vlc_volume_control) {}
    allow(player).to receive(:vlc_rc_connect) {}
    allow(Process).to receive(:wait) {}
    player.vlc(source)
  end
end

describe Budik::Player, '#vlc_build_command' do
  it 'correctly builds vlc command' do
    options['player'] = 'vlc'
    vlc_options = player.player_options
    vlc_options['path'] = 'C:/Program Files (x86)/VideoLAN/VLC/vlc.exe'
    vlc_options['rc_host'] = 'localhost'
    vlc_options['rc_port'] = 50_000
    vlc_options['volume_step'] = 1.0
    vlc_options['fullscreen'] = true
    source = { path: ['/tmp/test1.mp4', '/tmp/test2.mp4'] }

    cmd = '"C:/Program Files (x86)/VideoLAN/VLC/vlc.exe" --extraintf rc'\
      ' --rc-host localhost:50000 --volume-step 1.0 --fullscreen'\
      ' "file:///tmp/test1.mp4" "file:///tmp/test2.mp4" vlc://quit'
    expect(player.vlc_build_command(source)).to eq cmd
  end
end

describe Budik::Player, '#vlc_rc_connect' do
  it "attempts connection to VLC's remote control interface" do
    host = player.player_options['rc_host'] = 'localhost'
    port = player.player_options['rc_port'] = 50_000
    expect(player).to receive(:loop).and_yield
    expect(TCPSocket).to receive(:open).with(host, port)
    player.vlc_rc_connect
  end
end

describe Budik::Player, '#vlc_volume_control' do
  it 'lowers volume and fades back in' do
    player.player = 'vlc'
    player.player_options = options['vlc']
    player.player_options['volume_fadein_secs'] = 0
    volume = player.player_options['default_volume'] = 128
    step = player.player_options['volume_step'] = 1.0

    rc = instance_double('IO', puts: nil)
    expect(rc).to receive(:puts).with('volume ' + volume.to_s)
    expect(rc).to receive(:puts).with('volup ' + step.to_s).exactly(128).times
    player.vlc_volume_control(rc)
  end
end
