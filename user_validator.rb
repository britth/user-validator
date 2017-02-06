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

    pw_regex = pw.match(/(#{alpha_lc_num}|#{sp_num_alpha_l}|#{alpha_c_num_sp}).*/)
    if pw_regex.nil?
      true
    else
      (pw_regex[0].match(/^\S*$/) && pw_regex[0].length >= 6) ? false : true
    end
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
end
