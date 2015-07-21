class Options
    @@config = nil
    @@options = nil

    def self.load_config(override)
        if override
            load_options(override)
        else
            begin
                @@config = YAML.load_file('options.yml')
                options_dir = @@config['program']['options_dir']
                options_file = @@config['program']['options']
                options_path = options_dir + 'options-' + options_file + '.yml'
            rescue
                puts 'Error accessing your configuration files. Restoring default.'
                config = Hash.new
                config['program'] = program_config = Hash.new
                program_config['lang'] = 'en'
                program_config['options_dir'] = 'options/'
                program_config['options'] = 'default'
                File.open('options.yml', 'w') do |f|
                    f.puts config.ya2yaml(syck_compatible: true)
                end
                options_path = 'options/options-default.yml'
            end
            load_options(options_path)
        end
    end

    def self.load_options(options)
        # TODO: Options-default doesn't exist
        @@options = YAML.load_file(options)
        get_options
    end

    def self.get_config(*categories)
        if categories.empty?
            @@config
        else
            config = @@config
            categories.each do |category|
                config = config[category]
            end
            config
        end
    end

    def self.get_options(*categories)
        if categories.empty?
            @@options
        else
            options = @@options
            categories.each do |category|
                options = options[category]
            end
            options
        end
    end
end
