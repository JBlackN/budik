#require 'r18n-core'
require 'singleton'
require 'spec_helper'
require 'yaml'

require 'budik/sources'

describe Budik::Sources, '#apply_mods' do
  it 'filters sources by applying modifiers' do
    Budik::Sources.instance.parse(YAML.load_file('./lib/budik/config/templates/sources_example.yml'))

    mods = {adds: [['category1']], rms: [['subcategory1']]}
    Budik::Sources.instance.apply_mods(mods)
    sources_expected_result = [
        {name: 'name',
         category: ['category1', 'subcategory2'],
         path: ['path1', 'path2']}
    ]

    expect(Budik::Sources.instance.sources).to eq sources_expected_result
    Budik::Sources.instance.sources = []
  end
end

describe Budik::Sources, '#parse' do
  context 'without modifiers' do
    it 'parses sources to program usable format' do
      sources_example = YAML.load_file('./lib/budik/config/templates/sources_example.yml')
      Budik::Sources.instance.parse(sources_example)
      sources_expected_result = [
        {name: 'path',
         category: ['default'],
         path: 'path'},
        
         {name: 'path1 + path2',
         category: ['default'],
         path: ['path1', 'path2']},
        
        {name: 'name',
         category: ['default'],
         path: 'path'},
        
        {name: 'name',
         category: ['category1', 'subcategory1'],
         path: 'path'},
        
        {name: 'name',
         category: ['category1', 'subcategory2'],
         path: ['path1', 'path2']},
        
        {name: 'name',
         category: ['category2', 'subcategory1'],
         path: ['path1', 'path2']}
      ]
      
      expect(Budik::Sources.instance.sources).to eq sources_expected_result
      Budik::Sources.instance.sources = []
     end
  end

  context 'with modifiers' do
    it 'parses sources to program usable format' do
      mods_example = '.subcategory1 .default category1'
      sources_example = YAML.load_file('./lib/budik/config/templates/sources_example.yml')
      Budik::Sources.instance.parse(sources_example, mods_example)
      sources_expected_result = [
         {name: 'name',
         category: ['category1', 'subcategory2'],
         path: ['path1', 'path2']}
      ]
      
      expect(Budik::Sources.instance.sources).to eq sources_expected_result
      Budik::Sources.instance.sources = []
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
