class Sources
    @@items = []

    def self.prepare_sources(path, mods = nil)
        sources = JSON.parse(File.read(path))
        if mods == nil || mods[:adds].empty?
            parse_categories(sources)
        else
            parse_mods(sources, mods, true)
        end
        parse_mods(sources, mods, false) if mods != nil && !mods[:rms].empty?
        return @@items
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
            @@items << item
        end
    end

    def self.remove_items(category)
        @@items -= category
    end
end
