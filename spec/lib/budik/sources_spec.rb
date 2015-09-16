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

describe Budik::Sources, '#get' do
  context 'using number' do
    it 'returns correct source' do
      sources.sources = [1, 2, 3, 4, 5]
      expect(sources.get(1)).to eq 2
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
