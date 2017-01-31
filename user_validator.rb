require 'csv'

class UserValidator
  attr_reader :data
  def initialize(filename)
    @data = CSV.read( filename, { headers:           true,
                  converters:        :numeric,
                  header_converters: :symbol }.merge(Hash.new) )
  end

  def data
    i = 0
    @data.each do |row|
      row[:id] = i+=1
    end
  end

  def is_number?(value)
    true if Float(value) rescue false
  end

  def is_not_number?(value)
    false if Float(value) rescue true
  end

  def invalid_phone?(row)
    phone = row[:phone].to_s
    phone.
      match(/^(?:|[\(])[1-9]\d{2}(?:[\)] |[\)]|-|.|)[1-9]\d{2}(?:-|.|)\d{4}$/).
      nil?
  end

  def invalid_age?(row)
    age = row[:age].to_s
    is_not_number?(age) || age.to_s.match(/^[1]?[0-9][0-9]$/).nil?
  end

  def invalid_date?(row)
    date = row[:joined].to_s
    date.
      match(/^([0][1-9]|[1][0-2]|\d{1})[-\/.]([0-2][0-9]|[3][0-1]|\d{1})[-\/.](\d{2}|\d{4})$/).
      nil? &&
    date.
      match(/^\d{4}[-\/.]([0][1-9]|[1][0-2]|\d{1})[-\/.]([0-2][0-9]|[3][0-1]|\d{1})$/).
      nil?
  end

  def invalid_email?(row)
    e = row[:email].to_s
    s =  "!#$%&'*+-/=?^_`{|}~"
    e.match(/^((\w+\.{0,1}\w+)+|([\w#{s}]+))@\w([\-\w]|(\w\.\w))*\.\w+$/).nil?

  end

  def invalid_password?(row)
    pw = row[:password].to_s
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
    errors << 'Invalid age' if invalid_age?(row)
    errors << 'Invalid phone' if invalid_phone?(row)
    errors << 'Invalid date' if invalid_date?(row)
    errors << 'Invalid email' if invalid_email?(row)
    errors << 'Invalid password' if invalid_password?(row)
    errors
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
    invalid_phone?(row) || invalid_age?(row) ||
      invalid_date?(row) || invalid_email?(row) ||
      invalid_password?(row)
  end

  def invalid_rows
    data.select { |r| invalid?(r) }
  end

  def invalid_rows_and_errors
    invalid_rows.map { |r| [errors(r), r] }
  end

  def invalid_row_numbers
    invalid_rows.map { |r| r[:id] }.join(", ")
  end

  def invalid_phone_rows
    data.select { |r| invalid_phone?(r) }
  end

  def invalid_age_rows
    data.select { |r| invalid_age?(r) }
  end

  def invalid_join_date_rows
    data.select { |r| invalid_date?(r) }
  end

  def invalid_email_rows
    data.select { |r| invalid_email?(r) }
  end

  def invalid_password_rows
    data.select { |r| invalid_password?(r) }
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
    puts valid_rows
    puts "\n"

    puts "The following row number#{plural(invalid_rows.count)} " +
      "#{were_was(invalid_rows.count)} invalid: #{invalid_row_numbers}"

    # invalid_rows_and_errors.map{|r|
    #   puts "\n"+r.first.join(", ").to_s + "\n"+ r.last.to_s
    # }
    final = invalid_rows.map do |row|
      "\n"+row[:id].to_s+" "+row[:name].to_s+"\n"+print_errors(row).map{|x| x.to_s}.join("\n")
    end
    puts final
  end

  def format_values
    valid_rows = @data.select{|row| not invalid?(row)}
    valid_rows.map do |row|
      stripped_phone = row[:phone].gsub(/\D/, '')
      row[:phone] = '(' + stripped_phone[0..2] + ') ' +
                    stripped_phone[3..5] + '-' + stripped_phone[6..-1]
      row
      # d = r.at(header.first.index('date'))
      # d_stripped = r.at(header.first.index('date')).gsub(/\D/, '')
      # d_idx = header.first.index('date')
      # if not d.match(/^([0][1-9]|[1][0-2]|\d{1})[-\/.]([0-2][0-9]|[3][0-1]|\d{1})[-\/.](\d{2}|\d{4})$/).nil?
      #   r[d_idx] =
      # else
      #   r[d_idx] =
    end
  end

  def valid_rows
    @data.select { |r| not invalid?(r) }.map { |r| r.to_s }
    format_values.map { |r| r.to_s }
  end
end

# u = UserValidator.new('homework.csv')
#
# puts u.overall_summary
