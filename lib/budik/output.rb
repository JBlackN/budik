module Budik
  class Output
    include Singleton

    def initialize
      @strings = Config.instance.lang.output
    end

    def run_info_table(number, name)
      rows = []
      rows << [@strings.date, DateTime.now.strftime('%d/%m/%Y %H:%M')]
      rows << [@strings.number, number.to_s]
      rows << [@strings.alarm, name]

      Terminal::Table.new title: 'Budik', rows: rows
    end
  end
end
