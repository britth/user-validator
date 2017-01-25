require 'minitest/autorun'
require 'minitest/pride'
require './user_validator.rb'

class UserValidatorTest < Minitest::Test


  def setup
    @u = UserValidator.new('homework.csv')
  end

  def test_initialize
    assert UserValidator.new('homework.csv')
  end

  def test_correct_number_of_data_rows_are_returned
    #u = UserValidator.new('homework.csv')

    assert_equal(@u.all_rows.count, 7)
    assert_equal(@u.header.count, 1)
  end

  def test_correct_number_of_invalid_rows_based_on_phone
    #u = UserValidator.new('homework.csv')

    assert_equal(@u.invalid_phone_rows.count, 3)
  end

  def test_correct_number_of_invalid_rows_based_on_age
    #u = UserValidator.new('homework.csv')

    assert_equal(@u.invalid_age_rows.count, 0)
  end

  def test_correct_number_of_invalid_rows_based_on_join_date
    assert_equal(@u.invalid_join_date_rows.count, 4)
  end
end
