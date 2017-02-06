require './user_validator_formatter.rb'

class UserValidatorSummary
  attr_accessor :user_validator, :formatter
  def initialize(params = {})
    @user_validator = params.fetch(:user_validator, user_validator)
    @formatter = params.fetch(:formatter, formatter)
  end

  def user_validator
    @user_validator
  end

  def formatter
    @formatter
  end

  def print_errors(row)
    errors = []
    errors << 'Invalid age: ' + row[:age].to_s if user_validator.invalid_age?(row)
    errors << 'Invalid phone: ' + row[:phone].to_s if user_validator.invalid_phone?(row)
    errors << 'Invalid date: ' + row[:joined].to_s if user_validator.invalid_date?(row)
    errors << 'Invalid email: ' + row[:email].to_s if user_validator.invalid_email?(row)
    errors << 'Invalid password: ' + row[:password].to_s if user_validator.invalid_password?(row)
    errors
  end

  def plural(value)
    value != 1 ? 's' : ''
  end

  def were_was(value)
    value != 1 ? 'were' : 'was'
  end

  def overall_summary
    puts "There #{were_was(user_validator.valid_rows.count)} " +
      "#{user_validator.valid_rows.count} valid " +
      "row#{plural(user_validator.valid_rows.count)}."+
      "\n\n"
    puts user_validator.valid_rows.map{|row| formatter.valid_formatting(row)}
    puts "\n"

    puts "The following row " +
          "number#{plural(user_validator.invalid_rows.count)} " +
          "#{were_was(user_validator.invalid_rows.count)} invalid: " +
          "#{user_validator.invalid_row_numbers}"

    invalid_rows_with_errors = user_validator.invalid_rows.map{|row| "\n" + row[:id].to_s +
      " " + row[:name].to_s + "\n" + print_errors(row).map { |x| x.to_s }.join("\n")
    }
    puts invalid_rows_with_errors
  end
end
