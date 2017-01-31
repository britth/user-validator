require 'minitest/autorun'
require 'minitest/pride'
require './user_validator.rb'

class UserValidatorTest < Minitest::Test


  def setup
    @validator_1 = UserValidator.new('homework.csv')
    @validator_2 = UserValidator.new('homework2.csv')
  end

  def test_initialize
    assert UserValidator.new('homework.csv')
    assert UserValidator.new('homework2.csv')
  end

  def test_correct_number_of_invalid_rows_based_on_phone
    assert_equal(3, @validator_1.invalid_phone_rows.count)
    assert_equal(3, @validator_2.invalid_phone_rows.count)
  end

  def test_correct_number_of_invalid_rows_based_on_age
    assert_equal(@validator_1.invalid_age_rows.count, 0)
    assert_equal(@validator_2.invalid_age_rows.count, 0)
  end

  def test_correct_number_of_invalid_rows_based_on_join_date
    assert_equal(@validator_1.invalid_join_date_rows.count, 4)
    assert_equal(@validator_2.invalid_join_date_rows.count, 4)
  end

  def test_correct_number_of_invalid_rows_based_on_email
    assert_equal(@validator_1.invalid_email_rows.count, 2)
    assert_equal(@validator_2.invalid_email_rows.count, 2)
  end

  def test_correct_number_of_invalid_rows_based_on_password
    assert_equal(@validator_1.invalid_password_rows.count, 5)
    assert_equal(@validator_2.invalid_password_rows.count, 5)
  end

  def test_correct_number_of_all_invalid_rows
    assert_equal(@validator_1.invalid_rows.count, 7)
    assert_equal(@validator_2.invalid_rows.count, 7)
  end
end
