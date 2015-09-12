require 'fileutils'
require 'singleton'
require 'spec_helper'
require 'yaml'
require 'youtube_addy'

require 'budik/sources'

describe Budik::Sources, '#apply_mods' do
  it 'filters sources by applying modifiers' do
    Budik::Sources.instance.sources = []
    Budik::Sources.instance.parse(YAML.load_file('./lib/budik/config/templates/sources_example.yml'))

    mods = {
      adds: [
        ['category1', 'subcategory2'],
        ['category2', 'subcategory1']
      ],
      rms: [
        ['category2', 'subcategory1', 'subsubcategory1']
      ]
    }
    Budik::Sources.instance.apply_mods(mods)
    sources_expected_result = [
        {name: 'path',
         category: ['category1', 'subcategory2'],
         path: ['path']},

        {name: 'path3',
         category: ['category2', 'subcategory1', 'subsubcategory2'],
         path: ['path3']}
    ]

    expect(Budik::Sources.instance.sources).to eq sources_expected_result
  end
end

describe Budik::Sources, '#count' do
  it 'returns correct count of sources' do
    Budik::Sources.instance.sources = [1, 2, 3]
    expect(Budik::Sources.instance.count).to eq 3
  end
end

describe Budik::Sources, '#download' do # TODO: rewrite
  context 'using specified number' do
    it 'downloads an item' do
      config = Budik::Config.instance
      config.options['sources']['download']['dir'] = './spec/'

      sources_example = [
        {name: 'Test item 1',
         category: ['test'],
         path: ['https://www.youtube.com/watch?v=ghxo4OMh1YU']},

        {name: 'Test item 2',
         category: ['test'],
         path: ['https://www.youtube.com/watch?v=tPEE9ZwTmy0',
                'https://www.youtube.com/watch?v=wGyUP4AlZ6I']}
      ]
      Budik::Sources.instance.sources = sources_example

      Budik::Sources.instance.download(0)
      expect(File.file? './spec/ghxo4OMh1YU.mp4').to eq true
      FileUtils.rm './spec/ghxo4OMh1YU.mp4', force: true

      Budik::Sources.instance.download(1)
      expect(File.file? './spec/tPEE9ZwTmy0.mp4').to eq true
      expect(File.file? './spec/wGyUP4AlZ6I.mp4').to eq true
      FileUtils.rm './spec/tPEE9ZwTmy0.mp4', force: true
      FileUtils.rm './spec/wGyUP4AlZ6I.mp4', force: true
    end
  end

  context 'by default' do
    it 'downloads all items' do
      Budik::Sources.instance.download

      expect(File.file? './spec/ghxo4OMh1YU.mp4').to eq true
      expect(File.file? './spec/tPEE9ZwTmy0.mp4').to eq true
      expect(File.file? './spec/wGyUP4AlZ6I.mp4').to eq true
      FileUtils.rm './spec/ghxo4OMh1YU.mp4', force: true
    end
  end
end

describe Budik::Sources, '#download_youtube' do
  it 'downloads a video from YouTube' do
    test_address = 'https://www.youtube.com/watch?v=ghxo4OMh1YU'
    test_dir = './spec/'
    Budik::Sources.instance.download_youtube(test_address, test_dir)

    expect(File.file? './spec/ghxo4OMh1YU.mp4').to eq true
  end
end

describe Budik::Sources, '#parse' do
  context 'without modifiers' do
    it 'parses sources to program usable format' do
      sources_example = YAML.load_file('./lib/budik/config/templates/sources_example.yml')
      Budik::Sources.instance.sources = []
      Budik::Sources.instance.parse(sources_example)
      sources_expected_result = [
        {name: 'path',
         category: ['category1', 'subcategory1'],
         path: ['path']},
        
        {name: 'path1 + path2',
         category: ['category1', 'subcategory1'],
         path: ['path1', 'path2']},
        
        {name: 'name',
         category: ['category1', 'subcategory1'],
         path: ['path']},
        
        {name: 'name',
         category: ['category1', 'subcategory1'],
         path: ['path1', 'path2']},
        
        {name: 'path',
         category: ['category1', 'subcategory2'],
         path: ['path']},
        
        {name: 'path1',
         category: ['category2', 'subcategory1', 'subsubcategory1'],
         path: ['path1']},
        
        {name: 'path2',
         category: ['category2', 'subcategory1', 'subsubcategory1'],
         path: ['path2']},
        
        {name: 'path3',
         category: ['category2', 'subcategory1', 'subsubcategory2'],
         path: ['path3']},
        
        {name: 'path4',
         category: ['category2', 'subcategory2'],
         path: ['path4']}
      ]
      
      expect(Budik::Sources.instance.sources).to eq sources_expected_result
     end
  end

  context 'with modifiers' do
    it 'parses sources to program usable format' do
      mods_example = '.subcategory1 category1'
      sources_example = YAML.load_file('./lib/budik/config/templates/sources_example.yml')
      Budik::Sources.instance.sources = []
      Budik::Sources.instance.parse(sources_example, mods_example)
      sources_expected_result = [
         {name: 'path',
         category: ['category1', 'subcategory2'],
         path: ['path']}
      ]
      
      expect(Budik::Sources.instance.sources).to eq sources_expected_result
    end
  end
end

describe Budik::Sources, '#parse_mods' do
  it 'parses string with modifiers' do
    parsed_mods = Budik::Sources.instance.parse_mods('a.b c.d.e .f .g.h i .j k.l .m.n.o')
    expected_result = { adds: [['a', 'b'], ['c', 'd', 'e'], ['i'], ['k', 'l']], rms: [['f'], ['g', 'h'], ['j'], ['m', 'n', 'o']]}

    expect(parsed_mods).to eq expected_result
  end
end

describe Budik::Sources, '#remove' do
  context 'using specified number' do
    it 'removes downloaded file' do
      Budik::Config.instance.options['sources']['download']['keep'] = false
      sources_example = [
        {name: 'Test item 1',
         category: ['test'],
         path: ['https://www.youtube.com/watch?v=ghxo4OMh1YU']},

        {name: 'Test item 2',
         category: ['test'],
         path: ['https://www.youtube.com/watch?v=tPEE9ZwTmy0',
                'https://www.youtube.com/watch?v=wGyUP4AlZ6I']}
      ]
      Budik::Sources.instance.sources = sources_example

      Budik::Sources.instance.remove(0)
      id = YouTubeAddy.extract_video_id(sources_example[0][:path][0])
      expect(File.file?('./spec/' + id + '.mp4')).to eq false
    end
  end

  context 'by default' do
    it 'removes all downloaded files' do
      Budik::Config.instance.options['sources']['download']['keep'] = false
      sources_example = [
        {name: 'Test item 1',
         category: ['test'],
         path: ['https://www.youtube.com/watch?v=ghxo4OMh1YU']},

        {name: 'Test item 2',
         category: ['test'],
         path: ['https://www.youtube.com/watch?v=tPEE9ZwTmy0',
                'https://www.youtube.com/watch?v=wGyUP4AlZ6I']}
      ]
      Budik::Sources.instance.sources = sources_example

      Budik::Sources.instance.remove
      id1 = YouTubeAddy.extract_video_id(sources_example[1][:path][0])
      id2 = YouTubeAddy.extract_video_id(sources_example[1][:path][1])
      expect(File.file?('./spec/' + id1 + '.mp4')).to eq false
      expect(File.file?('./spec/' + id2 + '.mp4')).to eq false
    end
  end
end
