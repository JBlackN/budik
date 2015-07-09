require 'youtube_addy'

class Sources
    @@sources = []

    def self.load_sources(path, mods = nil)
        sources = JSON.parse(File.read(path))
        if mods == nil || mods[:adds].empty?
            parse_categories(sources)
        else
            parse_mods(sources, mods, true)
        end
        parse_mods(sources, mods, false) if mods != nil && !mods[:rms].empty?
        return @@sources
    end

    def self.parse_categories(categories, rm = false)
        categories.each do |category, subcategory|
            if (subcategory.is_a? Hash)
                parse_categories(subcategory, rm)
            else
                parse_items(subcategory) unless rm
                remove_items(subcategory) if rm
            end
        end
    end

    def self.parse_mods(categories, mods, add)
        mods[add ? :adds : :rms].each do |mod|
            category = categories
            mod.each do |subcategory|
                category = category[subcategory]
            end
            if (add)
                parse_items(category) unless category.is_a? Hash
                parse_categories(category) if category.is_a? Hash
            else
                remove_items(category) unless category.is_a? Hash
                parse_categories(category, true) if category.is_a? Hash
            end
        end
    end

    def self.parse_items(category)
        category.each do |item|
            @@sources << item
        end
    end

    def self.remove_items(category)
        @@sources -= category
    end

    def self.sources_count
        @@sources.length
    end

    def self.get_source_by_number(number)
        @@sources[number]
    end

    def self.prepare_all(options)
        @@sources.each do |source|
            prepare_source(source, options)
        end
    end

    def self.normalize_source(source)
        if source.is_a? Array
            if source.first.is_a? Hash
                normalized_source = source
            elsif source.first.is_a? String
                normalized_source = []
                source.each do |path|
                    new_item = Hash.new
                    new_item["name"] = path
                    new_item["path"] = path
                    normalized_source << new_item
                end
            end
        elsif source.is_a? Hash
            if source["path"].is_a? Array
                normalized_source = []
                source["path"].each do |path|
                    new_item = Hash.new
                    new_item["name"] = source["name"]
                    new_item["path"] = path
                    normalized_source << new_item
                end
            elsif source["path"].is_a? String
                normalized_source = []
                normalized_source << source
            end
        elsif source.is_a? String
            normalized_source = []
            new_item = Hash.new
            new_item["name"] = source
            new_item["path"] = source
            normalized_source << new_item
        end

        return normalized_source
    end

    def self.prepare_source(source, options)
        source = normalize_source(source)
        dir = options["sources"]["download"]["dir"]
        source.each do |item|
            youtube_id = YouTubeAddy.extract_video_id(item["path"])
            unless youtube_id == nil
                item["path"] = youtube_id
                download(item, dir)
                dir = dir[-1, 1] == "/" || dir[-1, 1] == "\\" ? dir : dir + "/"
                item["path"] = dir + item["path"] + ".mp4"
            end
        end
        source
    end

    def self.download(item, dir)
        filename = item["path"] + ".mp4"
        unless File.file?(filename)
            system("cd " + dir + " && youtube-dl --id -f bestvideo[ext=mp4]+bestaudio[ext=m4a]/mp4 " + item["path"] + " && cd $OLDPWD")
        end
    end
end
