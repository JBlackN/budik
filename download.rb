def parse_sources(item)
    if item.is_a? Hash
        path = item["path"]
        if path.is_a? Array
            path.each do |subitem|
                download(subitem, download_dir) unless !is_remote(subitem)
            end
        else
            download(path, download_dir) unless !is_remote(path)
        end
    elsif item.is_a? Array
        item.each do |subitem|
            if subitem.is_a? Hash
                path = subitem["path"]
                download(path, download_dir) unless !is_remote(path)
            else
                download(subitem, download_dir) unless !is_remote(subitem)
            end
        end
    else
        download(item, download_dir) unless !is_remote(item)
    end
end

def download_sources(number)
    options = JSON.parse(File.read(opts.options ? opts.options : "./options.json"))
    sources = Sources::prepare_sources(opts.sources ? opts.sources : options["sources"]["path"], nil)
    download_dir = options["sources"]["download_dir"]

    download(path, download_dir) unless !is_remote(path)

    if number == :all
        sources.each do |item|
            parse_sources(item)
        end
    else
        download(sources[number], download_dir) unless !is_remote(sources[number])
    end
end

def is_remote(source)
    begin
        uri = URI.parse(source)
        true
    rescue URI::InvalidURIError
        false
    end
end

def download(source, download_dir)
    # TODO: Mount
    ok = system("cd " + download_dir + " && youtube-dl --id -f bestvideo[ext=mp4]+bestaudio[ext=m4a]/mp4 " + source + " && cd $OLDPWD")
end
