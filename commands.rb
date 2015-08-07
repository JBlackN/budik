def command_config(args, opts)
  Options::load_config(opts.options)

  new = opts.new != nil
  edit = opts.edit != nil
  set = opts.set != nil
  delete = opts.delete != nil
  app = opts.app != nil

  none = !new && !edit && !set && !delete && !app

  if none
    config_menu
  elsif new && !edit && !set && !delete && !app
    config_new(opts.new ? nil : opts.new)
  elsif edit && !new && !set && !delete && !app
    config_edit(opts.edit ? nil : opts.edit)
  elsif set && !new && !edit && !delete && !app
    config_set(opts.set ? nil : opts.set)
  elsif delete && !new && !edit && !set && !app
    config_delete(opts.delete ? nil : opts.delete)
  elsif app && !new && !edit && !set && !delete
    config_app
  else
    puts "Please use only one or none of the options new, edit, set, delete. This doesn't include global options."
  end
end

def command_run(args, opts)
  options = Options::load_config(opts.options)
  Sources::load_sources(opts.sources ? opts.sources : options['sources']['path'], opts.categories ? Sources::parse_category_mods(opts.categories) : (options['sources']['categories'] == 'all' ? nil : Sources::parse_category_mods(options['sources']['categories'])))
  number = opts.number ? opts.number : rng(options['rng'], Sources::sources_count , opts.rng ? opts.rng : nil)

  unless options['os'] == 'windows'
    Devices::storage_get(options['sources']['download'])
    Devices::storage_mount
  end
  source = Sources::prepare_source(Sources::get_source_by_number(number), options)
  Player::get(options['player'])
  Player::play(source)
  Sources::delete(source, options['os']) if options['sources']['download']['method'] == 'remove'
  unless options['os'] == 'windows'
    Devices::storage_unmount
    Devices::storage_sleep
  end
end

def command_set(args, opts)
end

def command_sources(args, opts)
  options = Options::load_config(opts.options)

  add = opts.add != nil
  list = opts.list != nil
  remove = opts.remove != nil
  download = opts.download != nil

  none = !add && !list && !remove && !download

  if none || (list && !add && !remove && !download)
    sources = Sources::load_sources(opts.sources ? opts.sources : options['sources']['path'], opts.list.is_a?(String) && opts.list != 'all' ? Sources::parse_category_mods(opts.list) : nil)
    ap sources
  elsif add && !list && !remove && !download
    sources = YAML.load_file(opts.sources ? opts.sources : options['sources']['path'])
    if opts.add.is_a? String
      new_item = YAML.load(opts.add)
      if new_item.is_a? String
        sources['default'] = [] unless sources['default'].is_a? Array
        sources['default'] << new_item
      elsif new_item.is_a? Hash
        unless new_item.has_key? 'path'
          puts 'Please specify path.'
          return
        end

        if new_item.has_key? 'category'
          category = new_item['category']
          if category.include? ' ' || category[0] == '.'
            fail 'Invalid category.'
          else
            sub_sources = sources
            category.split('.').each do |c|
              begin
                sub_sources = sub_sources[c]
              rescue
                sub_sources[c] = Hash.new
                sub_sources = sub_sources[c]
              end
            end
            new_item.delete('category')
          end
        end

        if new_item.has_key? 'name'
          sub_sources << new_item
        else
          sub_sources << new_item['path']
        end
      end

      File.open(opts.sources ? opts.sources : options['sources']['path'], 'w') { |f| f.puts sources.ya2yaml(syck_compatible: true) }
    else
      puts 'Please specify what to add.'
    end
  elsif remove && !add && !list && !download
    # TODO
    puts 'TODO: Sources::remove_source'
  elsif download && !add && !list && !remove
    if opts.download == 'all' || opts.download == true
      # TODO: Options DL method check
      # TODO: Create dir if not exists (NO NEED)
      Sources::load_sources(opts.sources ? opts.sources : options['sources']['path'], nil)
      Sources::prepare_all(options)
    elsif opts.download.to_i.is_a? Integer
      # TODO
    elsif opts.download.is_a? String
      # TODO
    elsif opts.download.is_a? Hash
      # TODO
    end
  else
    puts "Please use only one or none of the options add, list, remove, or download. This doesn't include global options."
  end
end

def command_test(args, opts)
end

def command_translate(args, opts)
end
