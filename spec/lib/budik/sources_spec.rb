require 'spec_helper'

Budik::Config.instance
sources = Budik::Sources.instance
sources_path = './config/templates/sources/sources.yml'

describe Budik::Sources, '#apply_mods' do
  it 'correctly filters sources by applying modifiers' do
    sources.sources = []
    sources.parse(YAML.load_file(sources_path))

    mods = {
      adds: [
        %w(category1 subcategory2),
        %w(category2 subcategory1),
        ['category']
      ],
      rms: [
        %w(category2 subcategory1 subsubcategory1)
      ]
    }
    sources.apply_mods(mods)

    sources_expected_result = [
      { name: 'path',
        category: %w(category1 subcategory2),
        path: ['path'] },

      { name: 'path3',
        category: %w(category2 subcategory1 subsubcategory2),
        path: ['path3'] },

      { name: 'path',
        category: ['category'],
        path: ['path'] }
    ]
    expect(sources.sources).to eq sources_expected_result
  end
end

describe Budik::Sources, '#count' do
  it 'returns correct count of sources' do
    sources.sources = [1, 2, 3]
    expect(sources.count).to eq 3
  end
end

describe Budik::Sources, '#download' do # TODO: rewrite
  context 'using specified source' do
    it 'downloads an item' do
      sources_example = [
        { name: 'Test item 1',
          category: ['test'],
          path: ['https://www.youtube.com/watch?v=ghxo4OMh1YU'] },

        { name: 'Test item 2',
          category: ['test'],
          path: ['https://www.youtube.com/watch?v=tPEE9ZwTmy0',
                 'https://www.youtube.com/watch?v=wGyUP4AlZ6I'] }
      ]
      sources.sources = sources_example

      sources.download(sources.get(0))
      expect(File.file? sources.dir + 'ghxo4OMh1YU.mp4').to eq true
      FileUtils.rm sources.dir + 'ghxo4OMh1YU.mp4', force: true

      sources.download(sources.get(1))
      expect(File.file? sources.dir + 'tPEE9ZwTmy0.mp4').to eq true
      expect(File.file? sources.dir + 'wGyUP4AlZ6I.mp4').to eq true
      FileUtils.rm sources.dir + 'tPEE9ZwTmy0.mp4', force: true
      FileUtils.rm sources.dir + 'wGyUP4AlZ6I.mp4', force: true
    end
  end

  context 'by default' do
    it 'downloads all items' do
      sources.download

      expect(File.file? sources.dir + 'ghxo4OMh1YU.mp4').to eq true
      expect(File.file? sources.dir + 'tPEE9ZwTmy0.mp4').to eq true
      expect(File.file? sources.dir + 'wGyUP4AlZ6I.mp4').to eq true
      FileUtils.rm sources.dir + 'ghxo4OMh1YU.mp4', force: true
    end
  end
end

describe Budik::Sources, '#download_youtube' do
  it 'downloads a video from YouTube' do
    test_address = 'https://www.youtube.com/watch?v=ghxo4OMh1YU'
    sources.download_youtube(test_address)

    expect(File.file? sources.dir + 'ghxo4OMh1YU.mp4').to eq true
  end
end

describe Budik::Sources, '#get' do
  context 'using number' do
    it 'returns correct source' do
      sources.sources = [1, 2, 3, 4, 5]
      expect(sources.get(1)).to eq 2
    end
  end
end

describe Budik::Sources, '#locate_item' do
  context 'using YouTube link' do
    it 'returns location of downloaded video' do
      link = 'https://www.youtube.com/watch?v=oHg5SJYRHA0'
      sources.method = 'remove'
      location = sources.dir + 'oHg5SJYRHA0.mp4'
      expect(sources.locate_item(link)).to eq location
    end
  end

  context 'using YouTube link while streaming is enabled' do
    it "doesn't alter it" do
      link = 'https://www.youtube.com/watch?v=oHg5SJYRHA0'
      sources.method = 'stream'
      expect(sources.locate_item(link)).to eq link
    end
  end

  context 'using path to a local file' do
    it "doesn't alter it" do
      path = '/tmp/test.flac'
      sources.method = 'remove'
      expect(sources.locate_item(path)).to eq path
    end
  end
end

describe Budik::Sources, '#parse' do
  context 'without modifiers' do
    it 'parses sources to program usable format' do
      sources_example = YAML.load_file(sources_path)
      sources.sources = []
      sources.parse(sources_example)

      sources_expected_result = [
        { name: 'path',
          category: %w(category1 subcategory1),
          path: ['path'] },

        { name: 'path1 + path2',
          category: %w(category1 subcategory1),
          path: %w(path1 path2) },

        { name: 'name',
          category: %w(category1 subcategory1),
          path: ['path'] },

        { name: 'name',
          category: %w(category1 subcategory1),
          path: %w(path1 path2) },

        { name: 'path',
          category: %w(category1 subcategory2),
          path: ['path'] },

        { name: 'path1',
          category: %w(category2 subcategory1 subsubcategory1),
          path: ['path1'] },

        { name: 'path2',
          category: %w(category2 subcategory1 subsubcategory1),
          path: ['path2'] },

        { name: 'path3',
          category: %w(category2 subcategory1 subsubcategory2),
          path: ['path3'] },

        { name: 'path4',
          category: %w(category2 subcategory2),
          path: ['path4'] },

        { name: 'path',
          category: ['category'],
          path: ['path'] },

        { name: 'path2',
          category: %w(another_category category),
          path: ['path2'] }
      ]

      expect(sources.sources).to eq sources_expected_result
    end
  end
end

describe Budik::Sources, '#parse_mods' do
  it 'parses string with modifiers' do
    parsed_mods = sources.parse_mods('a.b c.d.e .f .g.h i .j k.l .m.n.o')
    expected_result = {
      adds: [%w(a b), %w(c d e), %w(i), %w(k l)],
      rms: [%w(f), %w(g h), %w(j), %w(m n o)]
    }

    expect(parsed_mods).to eq expected_result
  end
end

describe Budik::Sources, '#remove' do
  context 'using specified number' do
    it 'removes downloaded file' do
      sources.method = 'remove'
      sources_example = [
        { name: 'Test item 1',
          category: ['test'],
          path: ['https://www.youtube.com/watch?v=ghxo4OMh1YU'] },

        { name: 'Test item 2',
          category: ['test'],
          path: ['https://www.youtube.com/watch?v=tPEE9ZwTmy0',
                 'https://www.youtube.com/watch?v=wGyUP4AlZ6I'] }
      ]
      sources.sources = sources_example

      sources.remove(sources.get(0))
      id = YouTubeAddy.extract_video_id(sources_example[0][:path][0])
      expect(File.file?(sources.dir + id + '.mp4')).to eq false
    end
  end

  context 'by default' do
    it 'removes all downloaded files' do
      sources.method = 'remove'
      sources_example = [
        { name: 'Test item 1',
          category: ['test'],
          path: ['https://www.youtube.com/watch?v=ghxo4OMh1YU'] },

        { name: 'Test item 2',
          category: ['test'],
          path: ['https://www.youtube.com/watch?v=tPEE9ZwTmy0',
                 'https://www.youtube.com/watch?v=wGyUP4AlZ6I'] }
      ]
      sources.sources = sources_example

      sources.remove
      id1 = YouTubeAddy.extract_video_id(sources_example[1][:path][0])
      id2 = YouTubeAddy.extract_video_id(sources_example[1][:path][1])
      expect(File.file?(sources.dir + id1 + '.mp4')).to eq false
      expect(File.file?(sources.dir + id2 + '.mp4')).to eq false
    end
  end
end
