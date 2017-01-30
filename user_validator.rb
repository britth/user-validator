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
    value != 1 ? 's' : ''
  end

  def were_was(value)
    value != 1 ? 'were' : 'was'
  end

  def overall_summary
    puts "There #{were_was(valid_rows.count)} #{valid_rows.count} valid row#{plural(valid_rows.count)}."+
      "\n\n"

    puts "The following row number#{plural(invalid_rows.count)} " +
      "#{were_was(invalid_rows.count)} invalid: #{invalid_row_numbers}"

    invalid_rows_and_errors.map{|r|
      "\n"+r.first.join(", ").to_s + "\n"+ r.last.to_s
    }
  end

  def valid_rows
    @all_rows.select{|r| not invalid?(r)}.map{|r| r.to_s}
    format_values.map{|r| r.to_s}
  end

  def format_values
    v = @all_rows.select{|r| not invalid?(r)}
    v.map do |r|
      p = r.at(header.first.index('phone')).gsub(/\D/, '')
      idx = header.first.index('phone')
      r[idx] = '('+p[0..2]+') '+p[3..5]+'-'+p[6..-1]
    end
    v
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
    @all_rows.select{|r| invalid_phone?(r)}
  end

  def invalid_age_rows
    @all_rows.select{|r| invalid_age?(r)}
  end

  def invalid_join_date_rows
    @all_rows.select{|r| invalid_date?(r)}
  end

  def invalid_email_rows
    @all_rows.select{|r| invalid_email?(r)}
  end

  def invalid_password_rows
    @all_rows.select{|r| invalid_password?(r)}
  end

  def invalid?(row)
    invalid_phone?(row) || invalid_age?(row) ||
      invalid_date?(row) || invalid_email?(row) ||
      invalid_password?(row)
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

  def invalid_email?(row)
    e = row.at(header.first.index('email'))
    s =  "!#$%&'*+-/=?^_`{|}~"
    e.match(/^((\w+\.{0,1}\w+)+|([\w#{s}]+))@\w([\-\w]|(\w\.\w))*\.\w+$/).nil?

  end

  def invalid_password?(row)
    pw = row.at(header.first.index('password')).to_s
    s =  "!#$%&'*+-/=?^_`{|}~"
    alpha_lc_num = /((?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])[#{s}]*)/
    sp_num_alpha_l = /((?=.*[#{s}])(?=.*[0-9])(?=.*[a-z])[A-Z]*)/
    alpha_c_num_sp = /((?=.[A-Z])(?=.[0-9])(?=.[#{s}])[a-z]*)/

    rg = pw.match(/(#{alpha_lc_num}|#{sp_num_alpha_l}|#{alpha_c_num_sp}).*/)
    if rg.nil?
      true
    elsif rg[0].match(/^\S*$/) && rg[0].length >= 6
      false
    else
      true
    end
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
    if invalid_email?(row)
      errors << 'Invalid email'
    end
    if invalid_password?(row)
      errors << 'Invalid password'
    end
    errors
  end

end

# u = UserValidator.new('homework.csv')
#
# puts u.overall_summary
#
# puts u.valid_rows
#
# puts u.format_phone
