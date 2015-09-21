require 'spec_helper'

Budik::Config.instance
sources = Budik::Sources.instance
storage = Budik::Storage.instance

describe Budik::Storage, '#download_sources' do # TODO: rewrite
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
      sources.sources = storage.sources = sources_example

      storage.download_sources(sources.get(0))
      expect(File.file? storage.dir + 'ghxo4OMh1YU.mp4').to eq true
      FileUtils.rm storage.dir + 'ghxo4OMh1YU.mp4', force: true

      storage.download_sources(sources.get(1))
      expect(File.file? storage.dir + 'tPEE9ZwTmy0.mp4').to eq true
      expect(File.file? storage.dir + 'wGyUP4AlZ6I.mp4').to eq true
      FileUtils.rm storage.dir + 'tPEE9ZwTmy0.mp4', force: true
      FileUtils.rm storage.dir + 'wGyUP4AlZ6I.mp4', force: true
    end
  end

  context 'by default' do
    it 'downloads all items' do
      storage.download_sources

      expect(File.file? storage.dir + 'ghxo4OMh1YU.mp4').to eq true
      expect(File.file? storage.dir + 'tPEE9ZwTmy0.mp4').to eq true
      expect(File.file? storage.dir + 'wGyUP4AlZ6I.mp4').to eq true
      FileUtils.rm storage.dir + 'ghxo4OMh1YU.mp4', force: true
    end
  end
end

describe Budik::Storage, '#download_youtube' do
  it 'downloads a video from YouTube' do
    test_address = 'https://www.youtube.com/watch?v=ghxo4OMh1YU'
    storage.download_youtube('ghxo4OMh1YU', test_address)

    expect(File.file? storage.dir + 'ghxo4OMh1YU.mp4').to eq true
  end
end

describe Budik::Storage, '#locate_item' do
  context 'using YouTube link' do
    it 'returns location of downloaded video' do
      link = 'https://www.youtube.com/watch?v=oHg5SJYRHA0'
      storage.method = 'remove'
      location = storage.dir + 'oHg5SJYRHA0.mp4'
      expect(storage.locate_item(link)).to eq location
    end
  end

  context 'using YouTube link while streaming is enabled' do
    it "doesn't alter it" do
      link = 'https://www.youtube.com/watch?v=oHg5SJYRHA0'
      storage.method = 'stream'
      expect(storage.locate_item(link)).to eq link
    end
  end

  context 'using path to a local file' do
    it "doesn't alter it" do
      path = '/tmp/test.flac'
      storage.method = 'remove'
      expect(storage.locate_item(path)).to eq path
    end
  end
end

describe Budik::Storage, '#remove_sources' do
  context 'using specified number' do
    it 'removes downloaded file' do
      storage.method = 'remove'
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

      storage.remove_sources(sources.get(0))
      id = YouTubeAddy.extract_video_id(sources_example[0][:path][0])
      expect(File.file?(storage.dir + id + '.mp4')).to eq false
    end
  end

  context 'by default' do
    it 'removes all downloaded files' do
      storage.method = 'remove'
      sources_example = [
        { name: 'Test item 1',
          category: ['test'],
          path: ['https://www.youtube.com/watch?v=ghxo4OMh1YU'] },

        { name: 'Test item 2',
          category: ['test'],
          path: ['https://www.youtube.com/watch?v=tPEE9ZwTmy0',
                 'https://www.youtube.com/watch?v=wGyUP4AlZ6I'] }
      ]
      storage.sources = sources_example

      storage.remove_sources
      id1 = YouTubeAddy.extract_video_id(sources_example[1][:path][0])
      id2 = YouTubeAddy.extract_video_id(sources_example[1][:path][1])
      expect(File.file?(storage.dir + id1 + '.mp4')).to eq false
      expect(File.file?(storage.dir + id2 + '.mp4')).to eq false
    end
  end
end
