require 'minitest/autorun'
require 'minitest/pride'
require './user_validator.rb'

class UserValidatorTest < Minitest::Test


  def setup
    @u = UserValidator.new('homework.csv')
    @s = UserValidator.new('homework2.csv')
  end

  def test_initialize
    assert UserValidator.new('homework.csv')
    assert UserValidator.new('homework2.csv')
  end

  def test_correct_number_of_data_rows_are_returned
    #u = UserValidator.new('homework.csv')

    assert_equal(@u.all_rows.count, 7)
    assert_equal(@u.header.count, 1)
    assert_equal(@s.all_rows.count, 7)
    assert_equal(@s.header.count, 1)
  end

  def test_correct_number_of_invalid_rows_based_on_phone
    assert_equal(@u.invalid_phone_rows.count, 3)
    assert_equal(@s.invalid_phone_rows.count, 3)
  end

  def test_correct_number_of_invalid_rows_based_on_age
    assert_equal(@u.invalid_age_rows.count, 0)
    assert_equal(@s.invalid_age_rows.count, 0)
  end

  def test_correct_number_of_invalid_rows_based_on_join_date
    assert_equal(@u.invalid_join_date_rows.count, 4)
    assert_equal(@s.invalid_join_date_rows.count, 4)
  end

  def test_correct_number_of_invalid_rows_based_on_email
    assert_equal(@u.invalid_email_rows.count, 2)
    assert_equal(@s.invalid_email_rows.count, 2)
  end

  def test_correct_number_of_invalid_rows_based_on_password
    assert_equal(@u.invalid_password_rows.count, 5)
    assert_equal(@s.invalid_password_rows.count, 5)
  end

  def test_correct_number_of_all_invalid_rows
    assert_equal(@u.invalid_rows.count, 7)
    assert_equal(@s.invalid_rows.count, 7)
  end
end
