module Budik
  # 'Output' class provides information to the user via console.
  class Output
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
  end
end
