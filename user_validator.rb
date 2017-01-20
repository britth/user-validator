require 'csv'

class UserValidator
  attr_reader :data
  def initialize(filename)
    @all_rows = []
    @header = []
    @count = 0
    @data = CSV.foreach(filename) do |row|
              if $INPUT_LINE_NUMBER == 1
                @header << row
              else
                all_rows << row
              end
            end
  end

  def header
    @header
  end

  def all_rows
    @all_rows
  end
end
