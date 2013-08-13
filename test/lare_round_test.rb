require_relative 'test_helper'
require 'bigdecimal'
require 'stringio'

class LareRoundTest < MiniTest::Unit::TestCase

  def test_lareRound_has_static_method_round
    assert_equal(true,LareRound.respond_to?(:round))
  end

  (1..9).each do |digit|
    (1..23).each do |items|
      (0..10).each do |precision|
        method_name = "test #{items} rounded items with last digit of #{digit} should sum up to rounded total of BigDecimal items with precision of #{precision}".gsub(' ','_')
        define_method method_name do
          decimal = BigDecimal.new("0."+"3"*precision+"#{digit}")
          arr = Array.new(items){decimal}
          rounded_total = arr.reduce(:+).round(precision)
          assert_equal(rounded_total,LareRound.round(arr,precision).reduce(:+).round(precision))
        end
      end
    end
  end

  def test_should_raise_if_precision_is_nil
    decimal = BigDecimal.new("0.1234")
    arr = Array.new(3){decimal}
    exception = assert_raises(LareRound::LareRoundError){
      LareRound.round(arr,nil)
    }
    assert_equal("precision must not be nil", exception.message)
  end

  def test_should_raise_if_precision_is_less_than_zero
    decimal = BigDecimal.new("0.1234")
    arr = Array.new(3){decimal}
    exception = assert_raises(LareRound::LareRoundError){
      LareRound.round(arr,-1)
    }
    assert_equal("precision must be greater or equal to 0", exception.message)
  end

  def test_should_raise_if_precision_is_not_a_number
    decimal = BigDecimal.new("0.1234")
    arr = Array.new(3){decimal}
    exception = assert_raises(LareRound::LareRoundError){
      LareRound.round(arr,"not_a_number")
    }
    assert_equal("precision must be a number", exception.message)
  end

  def test_should_raise_if_number_array_is_nil
    exception = assert_raises(LareRound::LareRoundError){
      LareRound.round(nil,2)
    }
    assert_equal("array_of_values must not be nil", exception.message)
  end

  def test_should_raise_if_number_array_is_empty
    exception = assert_raises(LareRound::LareRoundError){
      LareRound.round(nil,2)
    }
    assert_equal("array_of_values must not be nil", exception.message)
  end

  def test_should_raise_if_array_of_values_is_not_an_array
    exception = assert_raises(LareRound::LareRoundError){
      LareRound.round({:number => 3.2},2)
    }
    assert_equal("array_of_values must be an array", exception.message)
  end

  def test_should_raise_if_number_array_contains_invalid_values
    exception = assert_raises(LareRound::LareRoundError){
      LareRound.round([3.2, 1, "not_a_number", Exception.new, nil],2)
    }
    assert_equal("array_of_values contains not numeric values (3)", exception.message)
  end

  def test_should_warn_if_numbers_not_big_decimals
    out, err = capture_io do
      LareRound.round([1.2132, 12.21212, 323.23],2)
    end
    assert_match(/array_of_values contains non decimal values, you might loose precision or even wrong rounding results/, err)
  end

end
