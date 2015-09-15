require 'spec_helper'

describe Budik::Player, '#omx_build_command' do
  it 'correctly builds omxplayer command' do
    Budik::Config.instance.options['player']['player'] = 'omxplayer'
    player = Budik::Player.instance
    omx_options = player.player_options
    omx_options['path'] = 'omxplayer'
    omx_options['default_volume'] = -2100
    item = '/tmp/test.mp4'

    cmd = 'omxplayer --vol -2100 /tmp/test.mp4'
    expect(player.omx_build_command(item)).to eq cmd
  end
end

describe Budik::Player, '#vlc_build_command' do
  it 'correctly builds vlc command' do
    Budik::Config.instance.options['player']['player'] = 'vlc'
    player = Budik::Player.instance
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
