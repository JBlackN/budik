module Budik
  # 'Output' class provides information to the user via console.
  class IO
    include Singleton

    def initialize
      @strings = Config.instance.lang.output
    end

    def run_info_table(number, name)
      title = 'Budik - ' + DateTime.now.strftime('%d/%m/%Y %H:%M')

      rows = []
      rows << [@strings.alarm, name]
      rows << [@strings.number, number.to_s]

      Terminal::Table.new title: title, rows: rows
    end

    def sources_print(sources)
      sources.each_with_index do |source, index|
        puts '[' + index.to_s.light_white + '] ' + source[:name].yellow
      end
    end
  end
end
