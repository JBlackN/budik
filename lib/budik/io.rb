# = io.rb
# This file contains methods for managing application's input and output.
#
# == Contact
#
# Author::  Petr Schmied (mailto:jblack@paworld.eu)
# Website:: http://www.paworld.eu
# Date::    September 20, 2015

module Budik
  # 'Output' class provides information to the user via console.
  class IO
    include Singleton

    # Loads output strings in currently set language.
    def initialize
      @strings = Config.instance.lang.output
    end

    # Outputs table formatted information about selected source
    # to the console.
    #
    # - *Args*:
    #   - +source+ -> Selected source (Hash).
    #   - +number+ -> Number of selected source (Fixnum).
    #
    def run_info_table(source, number)
      title = 'Budik - ' + DateTime.now.strftime('%d/%m/%Y %H:%M')

      rows = []
      rows << [@strings.alarm, source[:name]]
      rows << [@strings.category, source[:category].to_s]
      rows << [@strings.number, number.to_s]

      Terminal::Table.new title: title, rows: rows
    end

    # Outputs formatted list of sources to the console.
    #
    # - *Args*:
    #   - +sources+ -> Parsed sources (Array of Hashes).
    #
    def sources_print(sources)
      sources.each_with_index do |source, index|
        puts '[' + index.to_s.light_white + '] ' + source[:name].yellow
      end
    end
  end
end
