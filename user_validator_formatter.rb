require './user_validator.rb'

class UserValidatorFormatter
  attr_accessor :user_validator
  def initialize(params = {})
    @user_validator = params.fetch(:user_validator, user_validator)
  end

  def user_validator
    @user_validator
  end

  @@month_day_year_regex = /^([0][1-9]|[1][0-2]|\d{1})[-\/.]([0-2][0-9]|[3][0-1]|\d{1})[-\/.](\d{2}|\d{4})$/

  def format_dates_with_leading_zero(number_s)
    if number_s.length == 2
      number_s
    else
      '0' + number_s
    end
  end

  def format_year_with_leading_values(year_s, month, day)
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
      row[:joined] = format_year_with_leading_values(stripped_date_three, stripped_date_one.to_i, stripped_date_two.to_i) +
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
