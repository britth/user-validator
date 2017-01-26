require 'csv'

class UserValidator
  attr_reader :data
  def initialize(filename)
    @all_rows = []
    @header = []
    @count = 0
    @data = CSV.foreach(filename) do |row|
              if $INPUT_LINE_NUMBER == 1
                @header << row.insert(0, 'id')
              else
                all_rows << row.insert(0, ($INPUT_LINE_NUMBER-1))
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

  def plural(value)
    if value != 1
      's'
    end
  end

  def were_was(value)
    if value != 1
      'were'
    else
      'was'
    end
  end

  def overall_summary
    puts "There were #{valid_rows.count} valid row#{plural(valid_rows.count)}."+
      "\n\n"

    puts "The following row number#{plural(invalid_rows.count)} " +
      "#{were_was(invalid_rows.count)} invalid: #{invalid_row_numbers}\n\n"

    invalid_rows_and_errors.map{|r|
      r.first.join(", ").to_s + "\n"+ r.last.to_s + "\n\n"
    }
  end

  def valid_rows
    @all_rows.select{|r| not invalid?(r)}.map{|r| r.to_s}
  end

  def invalid_rows
    @all_rows.select{|r| invalid?(r)}
  end

  def invalid_rows_and_errors
    invalid_rows.map{|r| [errors(r), r.to_s]}
  end

  def invalid_row_numbers
    invalid_rows.map{|r| r.first}.join(", ")
  end

  def invalid_phone_rows
    @all_rows.select{|r| invalid_phone?(r)}.map{|r| [r.to_s, errors(r)]}
  end

  def invalid_age_rows
    @all_rows.select{|r| invalid_age?(r)}.map{|r| [r.to_s, errors(r)]}
  end

  def invalid_join_date_rows
    @all_rows.select{|r| invalid_date?(r)}.map{|r| [r.to_s, errors(r)]}
  end

  def invalid?(row)
    invalid_phone?(row) || invalid_age?(row) || invalid_date?(row)
  end

  def invalid_phone?(row)
    phone = row.at(header.first.index('phone'))
    phone.
      match(/^(?:|[\(])[1-9]\d{2}(?:[\)] |[\)]|-|.|)[1-9]\d{2}(?:-|.|)\d{4}$/).
      nil?
  end

  def invalid_age?(row)
    age = row.at(header.first.index('age'))
    is_not_number?(age) || age.to_s.match(/^[1]?[0-9][0-9]$/).nil?
  end

  def invalid_date?(row)
    date = row.at(header.first.index('joined'))
    date.
      match(/^([0][1-9]|[1][0-2]|\d{1})[-\/.]([0-2][0-9]|[3][0-1]|\d{1})[-\/.](\d{2}|\d{4})$/).
      nil? &&
    date.
      match(/^\d{4}[-\/.]([0][1-9]|[1][0-2]|\d{1})[-\/.]([0-2][0-9]|[3][0-1]|\d{1})$/).
      nil?
  end


  def errors(row)
    errors = []
    if invalid_age?(row)
      errors << 'Invalid age'
    end
    if invalid_phone?(row)
      errors << 'Invalid phone'
    end
    if invalid_date?(row)
      errors << 'Invalid date'
    end
    errors
  end

end

u = UserValidator.new('homework.csv')

puts u.overall_summary
