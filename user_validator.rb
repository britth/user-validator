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

  def is_number?(value)
    true if Float(value) rescue false
  end

  def is_not_number?(value)
    false if Float(value) rescue true
  end

  def header
    @header
  end

  def all_rows
    @all_rows
  end

  def invalid_rows
    @all_rows.select{|x| invalid?(x)}.map{|x| [x.to_s, errors(x)]}
  end

  def invalid_phone_rows
    @all_rows.select{|x| invalid_phone?(x)}.map{|x| [x.to_s, errors(x)]}
  end

  def invalid_age_rows
    @all_rows.select{|x| invalid_age?(x)}.map{|x| [x.to_s, errors(x)]}
  end

  def invalid?(row)
    invalid_phone?(row) || invalid_age?(row)
  end

  def invalid_phone?(row)
    row.at(header.first.index('phone')).match(/^(?:|[\(])[1-9]\d{2}(?:[\)] |[\)]|-|.|)[1-9]\d{2}(?:-|.|)\d{4}$/).nil?
  end

  def invalid_age?(row)
    age = row.at(header.first.index('age'))
    is_not_number?(age) || age.to_s.match(/^[1]?[0-9][0-9]$/).nil?
  end

  def errors(row)
    errors = []
    if invalid_age?(row)
      errors << 'Invalid age'
    end
    if invalid_phone?(row)
      errors << 'Invalid phone'
    end
    errors
  end

end

u = UserValidator.new('homework.csv')

# puts u.invalid_rows
# # puts u.all_rows.map{|x| x[2]}
