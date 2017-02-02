require 'csv'

class UserValidator
  attr_reader :data
  def initialize(filename)
    @data = CSV.read( filename, { headers:           true,
                  converters:        :numeric,
                  header_converters: :symbol }.merge(Hash.new) )
  end

  @@special_characters = "!#$%&'*+-/=?^_`{|}~"
  @@phone_regex = /^(?:|[\(])[1-9]\d{2}(?:[\)] |[\)]|-|.|)[1-9]\d{2}(?:-|.|)\d{4}$/
  @@age_regex = /^[1]?[0-9][0-9]$/
  @@month_day_year_regex = /^([0][1-9]|[1][0-2]|\d{1})[-\/.]([0-2][0-9]|[3][0-1]|\d{1})[-\/.](\d{2}|\d{4})$/
  @@year_month_day_regex = /^\d{4}[-\/.]([0][1-9]|[1][0-2]|\d{1})[-\/.]([0-2][0-9]|[3][0-1]|\d{1})$/
  @@email_regex = /^((\w+\.{0,1}\w+)+|([\w#{@@special_characters}]+))@\w([\-\w]|(\w\.\w))*\.\w+$/

  def data
    row_id = 0
    @data.each do |row|
      row[:id] = row_id+=1
    end
  end

  def is_not_number?(value)
    false if Float(value) rescue true
  end

  def invalid_phone?(row)
    phone = row[:phone].to_s
    phone.match(@@phone_regex).nil?
  end

  def invalid_age?(row)
    age = row[:age].to_s
    is_not_number?(age) || age.to_s.match(@@age_regex).nil?
  end

  def invalid_date?(row)
    date = row[:joined].to_s
    date.match(@@month_day_year_regex).nil? && date.match(@@year_month_day_regex).nil?
  end

  def invalid_email?(row)
    email_ad = row[:email].to_s
    email_ad.match(@@email_regex).nil?
  end

  def invalid_password?(row)
    pw = row[:password].to_s
    alpha_lc_num = /((?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])[#{@@special_characters}]*)/
    sp_num_alpha_l = /((?=.*[#{@@special_characters}])(?=.*[0-9])(?=.*[a-z])[A-Z]*)/
    alpha_c_num_sp = /((?=.[A-Z])(?=.[0-9])(?=.[#{@@special_characters}])[a-z]*)/

    rg = pw.match(/(#{alpha_lc_num}|#{sp_num_alpha_l}|#{alpha_c_num_sp}).*/)
    if rg.nil?
      true
    else
      (rg[0].match(/^\S*$/) && rg[0].length >= 6) ? false : true
    end

  end

  def print_errors(row)
    errors = []
    errors << 'Invalid age: ' + row[:age].to_s if invalid_age?(row)
    errors << 'Invalid phone: ' + row[:phone].to_s if invalid_phone?(row)
    errors << 'Invalid date: ' + row[:joined].to_s if invalid_date?(row)
    errors << 'Invalid email: ' + row[:email].to_s if invalid_email?(row)
    errors << 'Invalid password: ' + row[:password].to_s if invalid_password?(row)
    errors

  end

  def invalid?(row)
    invalid_phone?(row) || invalid_age?(row) || invalid_date?(row) ||
    invalid_email?(row) || invalid_password?(row)
  end

  def invalid_rows
    data.select { |row| invalid?(row) }
  end

  def valid_rows
    data.select { |row| not invalid?(row) }
  end

  def invalid_row_numbers
    invalid_rows.map { |row| row[:id] }.join(", ")
  end

  def invalid_phone_rows
    data.select { |row| invalid_phone?(row) }
  end

  def invalid_age_rows
    data.select { |row| invalid_age?(row) }
  end

  def invalid_join_date_rows
    data.select { |row| invalid_date?(row) }
  end

  def invalid_email_rows
    data.select { |row| invalid_email?(row) }
  end

  def invalid_password_rows
    data.select { |row| invalid_password?(row) }
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
    puts valid_rows.map{|row| valid_formatting(row)}
    puts "\n"

    puts "The following row number#{plural(invalid_rows.count)} " +
      "#{were_was(invalid_rows.count)} invalid: #{invalid_row_numbers}"

    invalid_rows_with_errors = invalid_rows.map{|row| "\n" + row[:id].to_s +
      " " + row[:name].to_s + "\n" + print_errors(row).map { |x| x.to_s }.join("\n")
    }
    puts invalid_rows_with_errors
  end

  def format_dates_with_leading_zero(number_s)
    if number_s.length == 2
      number_s
    else
      '0' + number_s
    end
  end

  def format_year_with_leading_values_test(year_s, month, day)
    current_year_s = Time.now.year.to_s
    current_month = Time.now.month
    current_day = Time.now.day


    if year_s.length == 2
      current_year_s[-2..-1].to_i < year_s.to_i ||
      (current_year_s[-2..-1].to_i == year_s.to_i &&
      (current_month < month || (current_month <= month && current_day < day))) ?
        (current_year_s[0..1].to_i - 1).to_s + year_s : current_year_s[0..1].to_s + year_s
    else
      year_s
    end
  end

  def valid_formatting(row)
    stripped_phone = row[:phone].gsub(/\D/, '')
    row[:phone] = '(' + stripped_phone[0..2] + ') ' +
                    stripped_phone[3..5] + '-' + stripped_phone[6..-1]

    stripped_date = row[:joined].to_s.scan(/([\d]+)+/).flatten
    stripped_date_one = stripped_date.at(0)
    stripped_date_two = stripped_date.at(1)
    stripped_date_three = stripped_date.at(2)

    if row[:joined].match(@@month_day_year_regex)
      row[:joined] = format_year_with_leading_values_test(stripped_date_three, stripped_date_one.to_i, stripped_date_two.to_i) +
                      '-' + format_dates_with_leading_zero(stripped_date_one) +
                      '-' + format_dates_with_leading_zero(stripped_date_two)
    else
      row[:joined] = stripped_date_one + '-' +
                      format_dates_with_leading_zero(stripped_date_two) +
                      '-' + format_dates_with_leading_zero(stripped_date_three)
    end
    row
  end
end
# 
# u = UserValidator.new('homework.csv')
#
# puts u.overall_summary
