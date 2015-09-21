# Budík

[![Build Status](https://travis-ci.org/JBlackN/budik.svg?branch=master)](https://travis-ci.org/JBlackN/budik)
[![Dependency Status](https://gemnasium.com/JBlackN/budik.svg)](https://gemnasium.com/JBlackN/budik)
[![Code Climate](https://codeclimate.com/github/JBlackN/budik/badges/gpa.svg)](https://codeclimate.com/github/JBlackN/budik)
[![Coverage Status](https://coveralls.io/repos/JBlackN/budik/badge.svg?branch=master&service=github)](https://coveralls.io/github/JBlackN/budik?branch=master)
[![Inline docs](http://inch-ci.org/github/JBlackN/budik.svg?branch=master&style=shields)](http://inch-ci.org/github/JBlackN/budik)

Budík is a command line application that uses a list of your favorite songs or videos (local or YouTube) to randomly select and play one of them. When combined with cron, systemd timers or schtasks, it can be used as an alarm clock.

__Warning:__ The application is intended for casual use only. Occurence of bugs is possible, no matter how much I try to avoid them.

## Requirements

* OS/Platform (other are untested):
  * Windows 7+ (Powershell is needed)
  * Linux
  * Raspberry Pi
* Applications:
  * Ruby (> 1.9.2)
  * VLC media player (Windows, Linux) or omxplayer (Raspberry Pi)
  * FFmpeg or Libav
* If you need to (un)mount or spin down storage devices, these applications are tested:
  * Udisks2
  * Hdparm (read its documentation and take extra care)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'budik'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install budik

## Configuration

When the application is run for the first time, it automatically creates its configuration in `your_home_directory/.budik/`. Edit `options.yml` and `sources.yml` as needed.

For information about correct YAML syntax, look [here](http://learnxinyminutes.com/docs/yaml/).

### Options.yml - explanation

```yaml
os: "windows, linux or rpi"
lang: "language code (default: en)"
player:
  omxplayer:
    default_volume: "omxplayer's starting volume (default: -2100)"
    path: "path to omxplayer (default: omxplayer)"
    volume_step_secs: "pause between volume ups (default: 3, app uses 7 steps)"
  player: "player to use (vlc or omxplayer)"
  vlc:
    default_volume: "vlc's starting volume (128 (default) ~ 50%, 256 ~ 100%)"
    fullscreen: "self-explainatory (true (default) or false)"
    path: "path to vlc (default: vlc)"
    rc_host: "vlc's remote control interface host (default: localhost)"
    rc_port: "vlc's remote control interface port (default: 50000)"
    volume_fadein_secs: "pause between volume ups (default: 0.125)"
    volume_step: "self-explainatory (default: 1.0)"
    wait_secs_after_run: "give vlc time to start if needed (default: 5)"
    wait_secs_if_http: "not used in current version (default: 3)"
rng:
  hwrng:
    source: "/dev/urandom, /dev/random/ or /dev/hwrng"
  method: "hwrng, random.org, rand-hwrng-seed or rand"
  random.org:
    apikey: "your Random.org API key"
sources:
  download:
    device: "self-explainatory (example: /dev/sda)"
    dir: "where to download sources (default (except rpi): ~/.budik/downloads/)"
    method: "keep, remove, stream"
    mount: "mount command, you can use $device/$partition variables (example: udisksctl mount -b $partition)"
    partition: "self-explainatory (example: /dev/sda1)"
    sleep: "sleep command, you can use $device/$partition variables (example: sudo hdparm -y $device)"
    unmount: "unmount command, you can use $device/$partition variables (example: udisksctl unmount -b $partition)"
  path: "path to sources file (default: ~/.budik/sources.yml)"
tv:
  available: "self-explainatory (true or false)"
  use_if_no_video: "self-explainatory (true or false)"
  wait_secs_after_on: "give TV time to turn on (default: 15)"
```

### Sources.yml - explanation

* Category can't contain both items and subcategories.
* Every item must have a category (file has to contain at least one category)
* __Don't__ use backslashes in paths.

```yaml
category1:
  subcategory1:
    - "path"    # Unnamed single item
    -           # Unnamed multiple items
      - "path1"
      - "path2"
    - name:     # Named single item
      - "path"
    - name:     # Named multiple items
      - "path1"
      - "path2"
  subcategory2:
    - "path"
category2:
  subcategory1:
    subsubcategory1:
      - "path1"
      - "path2"
    subsubcategory2:
      - "path3"
  subcategory2:
    - "path4"
category:
  - "path"
another_category:
  category:
    - "path2"
```

## Usage

Linux:

    $ budik --help

Windows:

    $ budik.bat --help

### Scheduling

#### Cron

  * [Scheduling Tasks with Cron Jobs](http://code.tutsplus.com/tutorials/scheduling-tasks-with-cron-jobs--net-8800)

#### Systemd timers

  * [How to Use Systemd Timers](http://jason.the-graham.com/2013/03/06/how-to-use-systemd-timers/)
  * [systemd.timer — Timer unit configuration](http://www.freedesktop.org/software/systemd/man/systemd.timer.html)
  * [systemd.time — Time and date specifications](http://www.freedesktop.org/software/systemd/man/systemd.time.html)

#### Schtasks

  * [Schtasks.exe](https://msdn.microsoft.com/en-us/library/windows/desktop/bb736357(v=vs.85).aspx)
  * [Two Minute Drill: The Schtasks command](http://blogs.technet.com/b/askperf/archive/2010/05/14/two-minute-drill-the-schtasks-command.aspx)

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Todo (Ideas)

* [ ] Better sources management (add, remove, etc.)
* [ ] Scheduling without need to interact with external tools
* [ ] Download timeout
* [ ] Automatic download after sources change
* [ ] Better config management

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/JBlackN/budik. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

