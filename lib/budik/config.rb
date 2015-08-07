###############
# CONFIG MENU #
###############

def config_menu
  heading = 'Budík.rb configuration'
  puts "\n" + heading
  (1..(heading.length + 1)).each { print '=' }
  puts

  while true do
    choice = config_menu_prompt
    if choice =~ /^new( \S+)?$/
      if choice == 'new'
        name = ask('Please enter name of your new configuration: ') do |q|
          q.validate = /\S+/
          q.default = 'default'
        end
        config_new(name)
      else
        config_new(choice[4..choice.length])
      end
    elsif choice =~ /^edit( \S+)?$/
      if choice == 'edit'
        name = ask('Please enter name of a configuration you want to edit: ') do |q|
          q.validate = /\S+/
          q.default = 'default'
        end
        config_edit(name)
      else
        config_edit(choice[5..choice.length])
      end
    elsif choice =~ /^set( \S+)?$/
      if choice == 'set'
        name = ask('Please enter name of a configuration you want to set as default: ') do |q|
          q.validate = /\S+/
          q.default = 'default'
        end
        config_set(name)
      else
        config_set(choice[4..choice.length])
      end
    elsif choice =~ /^delete( \S+)?$/
      if choice == 'delete'
        name = ask('Please enter name of a configuration you want to delete: ') do |q|
          q.validate = /\S+/
          q.default = 'all except default'
        end
        config_delete(name)
      else
        config_delete(choice[7..choice.length])
      end
    elsif choice == 'quit'
      break
    end
  end
end

def config_menu_prompt
  puts
  options_dir = Options::get_config('program', 'options_dir')
  options_active = Options::get_config('program', 'options')
  configs = Dir[options_dir + '*.yml']
  if configs.empty?
    puts 'You have no configurations available!'
  else
    puts 'You have these configurations available:'
  end

  n = 0
  configs.each do |config|
    config.gsub!(/^(options|.+)\/options-(\S+)\.yml$/, '\2')
    default = config == options_active ? ' (*)' : ''
    puts "[#{n}]: #{config}" + default
    n += 1
  end

  choice = ask('What do you want to do (new [name], edit [name|number], set [name|number], delete [name|number], quit)? ') do |q|
    q.default = 'quit'
    q.validate = /^((new|edit|set|delete)( \S+)?|quit)$/
  end

  if choice =~ /^(new|edit|set|delete)( \d+)$/
    begin
      choice.gsub!(/\d+/, configs[choice.gsub(/[^0-9]/, '').to_i])
    rescue TypeError
      puts 'Invalid number.'
    end
  else
    choice
  end
end

##############
# NEW CONFIG #
##############

def config_new(name)
  options_dir = Options::get_config('program', 'options_dir')
  filename = name == nil ? (options_dir + 'options-default.yml') : (options_dir + 'options-' + name + '.yml')

  if !File.file?(filename) or agree('WARNING: This will reset your ' + filename + ' file. Do you want to proceed (y/n)? ')
    case agree('Do you want to use a template? ')
    when true
      template = config_use_template
      unless template == nil
        FileUtils.rm(filename) if File.file?(filename)
        FileUtils.cp(template, filename)
      end
    else
      config_new_wizard(filename)
    end
  end
end

def config_new_wizard(filename)
  heading = 'NEW CONFIGURATION: ' + filename
  puts "\n" + heading
  (1..heading.length).each { print '=' }
  puts

  options = Hash.new
  options['os'] = config_category_os
  options['player'] = config_category_player(options['os'])
  options['rng'] = config_category_rng(options['os'])
  options['sources'] = config_category_sources(options['os'])
  options['tv'] = config_category_tv(options['os'])

  result_heading = 'HERE IS YOUR NEW CONFIGURATION:'
  puts
  (1..result_heading.length).each { |x| print '=' }
  puts "\n" + result_heading
  (1..result_heading.length).each { |x| print '=' }
  puts

  options_yml = options.ya2yaml(syck_compatible: true)
  puts options_yml + "\n"
  File.open(filename, 'w') { |f| f.puts options_yml }

  # TODO: Set as default?
end

def config_use_template
  templates = Dir['options/templates/*.yml']
  puts 'You have these templates available:' unless templates.empty?

  n = 0
  templates.each do |template|
    puts "[#{n}]: #{template}"
    n += 1
  end

  choice = ask('Which one do you want to use (use -1 to cancel)? ', Integer) { |q| q.in = -1..(templates.length - 1) }
  choice == -1 ? nil : templates[choice]
end

###############
# EDIT CONFIG #
###############

def config_edit(name)
  options_dir = Options::get_config('program', 'options_dir')
  options_dir = options_dir[-1, 1] == '/' || options_dir[-1, 1] == "\\" ? options_dir : options_dir + '/'

  filename = name == nil ? (options_dir + 'options-default.yml') : (options_dir + 'options-' + name + '.yml')
  if !File.file?(filename)
    puts 'Error: ' + filename + " doesn't exist."
    case agree("Do you want to create new configuration named \"" + name + "\" (y/n)? ")
    when true
      config_new(name)
    end
  else
    config_edit_wizard(filename)
  end
end

def config_edit_wizard(filename)
  heading = 'EDIT CONFIGURATION: ' + filename
  puts "\n" + heading
  (1..heading.length).each { print '=' }
  puts

  options = YAML.load_file(filename)

  while true do
    puts
    category = ask("Which categories do you want to edit (all, os, player, rng, sources, tv)? Enter \"done\" after you finish editing: ") do |q|
      q.validate = /^all|os|player|rng|sources|tv|done$/
      q.default = 'all'
    end

    case category
    when 'all'
      options['os'] = os = config_category_os(options['os'])
      options['player'] = config_category_player(os, options['player'])
      options['rng'] = config_category_rng(os, options['rng'])
      options['sources'] = config_category_sources(os, options['sources'])
      options['tv'] = config_category_tv(os, options['tv'])
    when 'os'
      options['os'] = config_category_os(options['os'])
    when 'player'
      options['player'] = config_category_player(options['os'], options['player'])
    when 'rng'
      options['rng'] = config_category_rng(options['os'], options['rng'])
    when 'sources'
      options['sources'] = config_category_sources(options['os'], options['sources'])
    when 'tv'
      options['tv'] = config_category_tv(options['os'], options['tv'])
    when 'done'
      result_heading = 'HERE IS YOUR UPDATED CONFIGURATION:'
      puts
      (1..result_heading.length).each { print '=' }
      puts "\n" + result_heading
      (1..result_heading.length).each { print '=' }
      puts

      options_yml = options.ya2yaml(syck_compatible: true)
      puts options_yml + "\n"
      File.open(filename, 'w') { |f| f.puts options_yml }
      break
    else
      puts 'Edit config: Invalid category choice.'
      next
    end
  end
end

#####################
# CONFIG CATEGORIES #
#####################

def config_category_os(edit = nil)
  questions = Hash.new
  questions[:config_os] = 'Which platform is this configuration intended for (windows, unix, rpi)? '
  questions[:config_os] += '<' + edit + '> ' if edit != nil

  ask(questions[:config_os]) do |q|
    q.validate = /^windows|unix|rpi$/
    q.default = 'rpi'
  end
end

def config_category_player(os, edit = nil)
  player_heading = 'PLAYER CONFIGURATION:'
  puts "\n" + player_heading
  (1..player_heading.length).each { print '-' }
  puts

  questions = Hash.new
  questions[:player] = 'Please specify which player do you want to use (omxplayer, vlc): '
  questions[:omx_vol] = "Set omxplayer's default volume (in millibels, -10000-0): |-2100| "
  questions[:omx_path] = "Set omxplayer's command path: "
  questions[:omx_vol_step] = "Set omxplayer's volume step (pause between volume ups, in seconds, 0.001-600): |3| "
  questions[:vlc_vol] = "Set VLC player's default volume (0-1024: 64 = 25%, 128 = 50%, 192 = 75%, 256 = 100%)? |128| "
  questions[:vlc_fullscreen] = 'Do you want to set VLC player to start in fullscreen (y/n)? '
  questions[:vlc_path] = "Set VLC player's command path: "
  questions[:vlc_rchost] = "Set VLC player's remote control host: "
  questions[:vlc_rcport] = "Set VLC player's remote control port: |50000| "
  questions[:vlc_vol_fadein] = "Set VLC player's pause between volume ups, in seconds, 0.001-600): |0.125| "
  questions[:vlc_vol_step] = "Set VLC player's volume step (1.0-256.0): |1.0| "
  questions[:vlc_wait_run] = 'Set amount of seconds to give VLC time to start (0-600): |5| '
  questions[:vlc_wait_http] = 'Set amount of seconds to give VLC time to load remote source (0-600): |3| '

  if edit != nil
    questions[:player] += '<' + edit['player'] + '> '

    edit_omx = edit['omxplayer']
    questions[:omx_vol].gsub!(/: \|/, ': <' + edit_omx['default_volume'].to_s + '> |')
    questions[:omx_path] += '<' + edit_omx['path'] + '> '
    questions[:omx_vol_step].gsub!(/: \|/, ': <' + edit_omx['volume_step_secs'].to_s + '> |')

    edit_vlc = edit['vlc']
    questions[:vlc_vol].gsub!(/\? \|/, '? <' + edit_vlc['default_volume'].to_s + '> |')
    questions[:vlc_fullscreen] += '<' + (edit_vlc['fullscreen'] ? 'yes' : 'no') + '> '
    questions[:vlc_path] += '<' + edit_vlc['path'] + '> '
    questions[:vlc_rchost] += '<' + edit_vlc['rc_host'] + '> '
    questions[:vlc_rcport].gsub!(/: \|/, ': <' + edit_vlc['rc_port'].to_s + '> |')
    questions[:vlc_vol_fadein].gsub!(/: \|/, ': <' + edit_vlc['volume_fadein_secs'].to_s + '> |')
    questions[:vlc_vol_step].gsub!(/: \|/, ': <' + edit_vlc['volume_step'].to_s + '> |')
    questions[:vlc_wait_run].gsub!(/: \|/, ': <' + edit_vlc['wait_secs_after_run'].to_s + '> |')
    questions[:vlc_wait_http].gsub!(/: \|/, ': <' + edit_vlc['wait_secs_if_http'].to_s + '> |')
  end

  player_opts = edit != nil ? edit : Hash.new
  player_opts['player'] = ask(questions[:player]) do |q|
    q.validate = /^omxplayer|vlc$/
    q.default = os == 'rpi' ? 'omxplayer' : 'vlc'
  end

  case player_opts['player']
  when 'omxplayer'
    vlc_opts = config_player_defaults(:vlc)
    puts config_player_defaults(:omxplayer).to_yaml
    case agree('Do you want to use this default configuration for omxplayer (y/n)? ')
    when true
      omx_opts = config_player_defaults(:omxplayer)
    when false
      omx_opts = Hash.new
      omx_opts['default_volume'] = ask(questions[:omx_vol], Integer) do |q|
        q.in = -10000..0
        q.default = -2100
      end
      omx_opts['path'] = ask(questions[:omx_path]) do |q|
        q.default = 'omxplayer'
      end
      omx_opts['volume_step_secs'] = ask(questions[:omx_vol_step], Float) do |q|
        q.in = 0.001..600
        q.default = 3
      end
    end
  when 'vlc'
    omx_opts = config_player_defaults(:omxplayer)
    puts config_player_defaults(:vlc).to_yaml
    case agree('Do you want to use this default configuration for vlc (y/n)? ')
    when true
      vlc_opts = config_player_defaults(:vlc)
    when false
      vlc_opts = Hash.new
      vlc_opts['default_volume'] = ask(questions[:vlc_vol], Integer) do |q|
        q.in = 0..1024
        q.default = 128
      end
      fullscreen = ask(questions[:vlc_fullscreen]) do |q|
        q.validate = /^yes|no|y|n$/i
        q.default = 'yes'
      end
      vlc_opts['fullscreen'] = (fullscreen.upcase.include? 'Y') ? true : false
      vlc_opts['path'] = ask(questions[:vlc_path]) do |q|
        q.default = 'vlc'
      end
      vlc_opts['rc_host'] = ask(questions[:vlc_rchost]) do |q|
        q.default = 'localhost'
      end
      vlc_opts['rc_port'] = ask(questions[:vlc_rcport], Integer) do |q|
        q.in = 1...65536
        q.default = 50000
      end
      vlc_opts['volume_fadein_secs'] = ask(questions[:vlc_vol_fadein], Float) do |q|
        q.in = 0.001..600
        q.default = 0.125
      end
      vlc_opts['volume_step'] = ask(questions[:vlc_vol_step]) do |q|
        q.in = 1.0..256.0
        q.default = 1.0
      end
      vlc_opts['wait_secs_after_run'] = ask(questions[:vlc_wait_run], Integer) do |q|
        q.in = 0..600
        q.default = 5
      end
      vlc_opts['wait_secs_if_http'] = ask(questions[:vlc_wait_http], Integer) do |q|
        q.in = 0..600
        q.default = 3
      end
    end
  else
    fail 'Config: Invalid player choice'
  end
  player_opts['omxplayer'] = omx_opts
  player_opts['vlc'] = vlc_opts
  player_opts
end

def config_category_rng(os, edit = nil)
  rng_heading = 'RANDOM NUMBER GENERATION CONFIGURATION:'
  puts "\n" + rng_heading
  (1..rng_heading.length).each { print '-' }
  puts

  questions = Hash.new
  questions[:rng_method] = 'Please specify which random number generation method do you want to use (hwrng, random.org, rand-hwrng-seed, rand): '
  questions[:hwrng_src] = 'Set hwrng source: '
  questions[:rorg_apikey] = 'Enter your random.org API key: '

  if edit != nil
    questions[:rng_method] += '<' + edit['method'] + '> '
    questions[:hwrng_src] += '<' + edit['hwrng']['source'] + '> '
    questions[:rorg_apikey] += '<' + edit['random.org']['apikey'] + '> '
  end

  rng_opts = edit != nil ? edit : Hash.new
  rng_opts['method'] = ask(questions[:rng_method]) do |q|
    q.validate = /^hwrng|random.org|rand-hwrng-seed|rand$/
    q.default = os == 'windows' ? 'random.org' : 'hwrng'
  end

  case rng_opts['method']
  when 'hwrng'
    random_org_opts = config_rng_defaults(:random_org, os)
    puts config_rng_defaults(:hwrng, os).to_yaml
    case agree('Do you want to use this default configuration for hwrng (y/n)? ')
    when true
      hwrng_opts = config_rng_defaults(:hwrng, os)
    when false
      hwrng_opts = Hash.new
      hwrng_opts['source'] = ask(questions[:hwrng_src]) do |q|
        q.default = os == 'windows' ? '' : (os == 'rpi' ? '/dev/hwrng' : '/dev/random')
      end
    end
  when 'random.org'
    hwrng_opts = config_rng_defaults(:hwrng, os)
    puts config_rng_defaults(:random_org, os).to_yaml
    case agree('Do you want to use this default configuration for random.org (y/n)? ')
    when true
      random_org_opts = config_rng_defaults(:random_org, os)
    when false
      random_org_opts = Hash.new
      random_org_opts['apikey'] = ask(questions[:rorg_apikey]) do |q|
        q.default = ''
      end
    end
  else
    hwrng_opts = config_rng_defaults(:hwrng, os)
    random_org_opts = config_rng_defaults(:random_org, os)
  end
  rng_opts['hwrng'] = hwrng_opts
  rng_opts['random.org'] = random_org_opts
  rng_opts
end

def config_category_sources(os, edit = nil)
  src_heading = 'MEDIA SOURCES CONFIGURATION:'
  puts "\n" + src_heading
  (1..src_heading.length).each { print '-' }
  puts

  questions = Hash.new
  questions[:sources] = 'Please specify where is your file containing media sources located: '
  questions[:categories] = 'Please specify any category restrictions to apply when selecting source (separate categories by space, subcategories by dots; categories starting with dot will be excluded, instead of included): '
  questions[:device] = "Which device do you want to use (leave empty if your device isn't a HDD or if you don't want to spin your HDD down automatically after use by hdparm -y)? "
  questions[:partition] = "Which partition do you want to use (leave empty if you don't want Budík.rb to mount and unmount your device using udisks2)? "
  questions[:dl_dir] = 'Please specify directory where to store your remote media sources: '
  questions[:dl_method] = 'Please specify whether you want to store downloaded remote sources, or remove them (store, remove): '

  if edit != nil
    questions[:sources] += '<' + edit['path'] + '> '
    questions[:categories] += '<' + edit['categories'] + '> '

    edit_dl = edit['download']
    questions[:device] += '<' + edit_dl['device'] + '> '
    questions[:partition] += '<' + edit_dl['partition'] + '> '
    questions[:dl_dir] += '<' + edit_dl['dir'] + '> '
    questions[:dl_method] += '<' + edit_dl['method'] + '> '
  end

  src_opts = edit != nil ? edit : Hash.new
  src_opts['path'] = ask(questions[:sources]) do |q|
    q.default = 'sources.yml'
  end
  src_opts['categories'] = ask(questions[:categories]) do |q|
    q.validate = /^\.?[^. ]+(\.[^. ]+)*( \.?[^. ]+(\.[^. ]+)*)*$/
    q.default = 'all'
  end

  src_opts['download'] = download_opts = Hash.new
  case os
  when 'rpi'
    puts "WARNING: It is advised to use external storage with your Raspberry Pi. Doing otherwise could shorten your SD card's life span."
    download_opts['device'] = ask(questions[:device]) do |q|
      q.default = '/dev/sda'
    end
    download_opts['partition'] = ask(questions[:partition]) do |q|
      q.default = '/dev/sda1'
    end
    download_opts['sleep'] = download_opts['device'] == '' ? false : true
    download_opts['mount'] = download_opts['partition'] == '' ? false : true
    download_opts['dir'] = ask(questions[:dl_dir]) do |q|
      q.validate = /^.*\/$/
      q.default = '/mnt/Budík.rb/'
    end
    download_opts['method'] = ask(questions[:dl_method]) do |q|
      q.validate = /^store|remove$/
      q.default = 'remove'
    end
  when 'windows'
    download_opts['device'] = ''
    download_opts['partition'] = ''
    download_opts['sleep'] = false
    download_opts['mount'] = false
    download_opts['dir'] = ask(questions[:dl_dir]) do |q|
      q.validate = /^.*\/$/
      q.default = 'downloads/'
    end
    download_opts['method'] = ask(questions[:dl_method]) do |q|
      q.validate = /^store|remove$/
      q.default = 'remove'
    end
  when 'unix'
    case agree('Do you want to use an external device (y/n)? ')
    when true
      download_opts['device'] = ask(questions[:device]) do |q|
        q.default = '/dev/sda'
      end
      download_opts['partition'] = ask(questions[:partition]) do |q|
        q.default = '/dev/sda1'
      end
      download_opts['sleep'] = download_opts['device'] == '' ? false : true
      download_opts['mount'] = download_opts['partition'] == '' ? false : true
      download_opts['dir'] = ask(questions[:dl_dir]) do |q|
        q.validate = /^.*\/$/
        q.default = '/mnt/Budík.rb/'
      end
    else
      download_opts['device'] = ''
      download_opts['partition'] = ''
      download_opts['sleep'] = false
      download_opts['mount'] = false
      download_opts['dir'] = ask(questions[:dl_dir]) do |q|
        q.validate = /^.*\/$/
        q.default = 'downloads/'
      end
    end
    download_opts['method'] = ask(questions[:dl_method]) do |q|
      q.validate = /^store|remove$/
      q.default = 'remove'
    end
  end
  src_opts
end

def config_category_tv(os, edit = nil)
  tv_opts = edit != nil ? edit : Hash.new

  questions = Hash.new
  questions[:tv_connected] = 'Is TV connected to your Raspberry Pi using HDMI? Do you want to use it (y/n)? '
  questions[:tv_no_vid] = 'Do you want to use your TV for sources with no video (y/n)? '
  questions[:tv_wait_on] = 'How many seconds should program wait to give your TV time to turn on (0-120)? |15| '

  if edit != nil
    questions[:tv_connected] += '<' + (edit['available'] ? 'yes' : 'no') + '> '
    questions[:tv_no_vid] += '<' + (edit['use_if_no_video'] ? 'yes' : 'no') + '> '
    questions[:tv_wait_on].gsub!(/\? \|/, '? <' + edit['wait_secs_after_on'].to_s + '> |')
  end

  if os == 'rpi' || edit != nil
    tv_heading = 'TV CONFIGURATION:'
    puts "\n" + tv_heading
    (1..tv_heading.length).each { print '-' }
    puts

    tv_opts['available'] = agree(questions[:tv_connected])
    if tv_opts['available']
      tv_opts['use_if_no_video'] = agree(questions[:tv_no_vid])
      tv_opts['wait_secs_after_on'] = ask(questions[:tv_wait_on]) do |q|
        q.in = 0..120
        q.default = 15
      end
    end
  else
    tv_opts['available'] = false
    tv_opts['use_if_no_video'] = false
    tv_opts['wait_secs_after_on'] = 0
  end
  tv_opts
end

###################
# CONFIG DEFAULTS #
###################

def config_player_defaults(player)
  player_opts = Hash.new
  case player
  when :omxplayer
    player_opts['default_volume'] = -2100
    player_opts['path'] = 'omxplayer'
    player_opts['volume_step_secs'] = 3
  when :vlc
    player_opts['default_volume'] = 128
    player_opts['fullscreen'] = true
    player_opts['path'] = 'vlc'
    player_opts['rc_host'] = 'localhost'
    player_opts['rc_port'] = 50000
    player_opts['volume_fadein_secs'] = 0.125
    player_opts['volume_step'] = 1.0
    player_opts['wait_secs_after_run'] = 5
    player_opts['wait_secs_if_http'] = 3
  else
    fail 'Config: Invalid player choice'
  end
  player_opts
end

def config_rng_defaults(method, os)
  rng_opts = Hash.new
  case method
  when :hwrng
    rng_opts['source'] = os == 'windows' ? '' : (os == 'rpi' ? '/dev/hwrng' : '/dev/random')
  when :random_org
    rng_opts['apikey'] = ''
  else
    fail 'Case: Invalid RNG choice.'
  end
  rng_opts
end

##############
# SET CONFIG #
##############

def config_set(name)
  config = Options::get_config
  config['program']['options'] = name
  File.open('options.yml', 'w') do |f|
    f.puts config.ya2yaml(syck_compatible: true)
  end
end

#################
# DELETE CONFIG #
#################

def config_delete(name)
  options_dir = Options::get_config('program', 'options_dir')
  filename = options_dir + 'options-' + name + '.yml'
  
  questions = Hash.new
  questions[:del_check] = "Do you really want to delete configuration \"" + name + "\" (y/n)? "

  if !File.file?(filename)
    puts "Configuration \"" + name + "\" doesn't exist."
  else  
    FileUtils.rm(filename) if agree(questions[:del_check])
  end
end

##############
# APP CONFIG #
##############

def config_app
  heading = 'APP CONFIGURATION'
  puts "\n" + heading
  (1..heading.length).each { print '=' }
  puts

  config = Options::get_config
  puts config.to_yaml

  questions = Hash.new
  questions[:lang] = 'Set application language: <' + config['program']['lang'] + '> '
  questions[:opts_dir] = 'Enter path to directory with your application options files: <' + config['program']['options_dir'] + '> '

  config['program']['lang'] = ask(questions[:lang]) do |q|
    q.default = 'en'
  end
  config['program']['options_dir'] = ask(questions[:opts_dir]) do |q|
    q.validate = /^.*\/$/
    q.default = 'options/'
  end

  File.open('options.yml', 'w') do |f|
    f.puts config.ya2yaml(syck_compatible: true)
  end
end
