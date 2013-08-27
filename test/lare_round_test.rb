require_relative 'test_helper'
require 'bigdecimal'
require 'securerandom'

class LareRoundTest < MiniTest::Unit::TestCase

  def test_lareRound_has_static_method_round
    assert_equal(true,LareRound.respond_to?(:round))
  end

  (1..9).each do |digit|
    (1..23).each do |items|
      (0..10).each do |precision|

        method_name = "test #{items} rounded items with last digit of #{digit} should sum up to rounded total of BigDecimal items with precision of #{precision} if passed as array".gsub(' ','_')
        define_method method_name do
          decimal = BigDecimal.new("0."+"3"*precision+"#{digit}")
          arr = Array.new(items){decimal}
          rounded_total = arr.reduce(:+).round(precision)
          assert_equal(rounded_total,LareRound.round(arr,precision).reduce(:+).round(precision))
        end

        method_name = "test #{items} rounded items with last digit of #{digit} should sum up to rounded total of BigDecimal items with precision of #{precision} if passed as hash".gsub(' ','_')
        define_method method_name do
          decimal = BigDecimal.new("0."+"3"*precision+"#{digit}")
          hash = Hash[(1..items).map.with_index{|x,i|[x,decimal]}]
          rounded_total = hash.values.reduce(:+).round(precision)
          assert_equal(rounded_total,LareRound.round(hash,precision).values.reduce(:+).round(precision))
        end

        method_name = "test #{items} rounded items with last digit of #{digit} and precision of #{precision} if passed as hash should not change order".gsub(' ','_')
        define_method method_name do
          decimal = BigDecimal.new("0."+"3"*precision+"#{digit}")
          hash = Hash[(1..items).map.with_index{|x,i|[x,decimal+BigDecimal.new(i)]}]
          rounded_hash = LareRound.round(hash.clone,precision)
          hash.keys.each do |key|
            assert( (((hash[key] - rounded_hash[key])*10**precision).abs < 1) )
          end
        end

        method_name = "test #{items} rounded negative items with last digit of #{digit} should sum up to rounded total of BigDecimal items with precision of #{precision} if passed as array".gsub(' ','_')
        define_method method_name do
          decimal = BigDecimal.new("-0."+"3"*precision+"#{digit}")
          arr = Array.new(items){decimal}
          rounded_total = arr.reduce(:+).round(precision)
          assert_equal(rounded_total,LareRound.round(arr,precision).reduce(:+).round(precision))
        end

        method_name = "test #{items} rounded mixed (+/-) items with last digit of #{digit} should sum up to rounded total of BigDecimal items with precision of #{precision} if passed as array".gsub(' ','_')
        define_method method_name do
          decimal = BigDecimal.new( (SecureRandom.random_number(100) % 2 == 0) ? "" : "-" + "0."+"3"*precision+"#{digit}")
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

  def test_should_raise_if_values_is_nil
    exception = assert_raises(LareRound::LareRoundError){
      LareRound.round(nil,2)
    }
    assert_equal("values must not be nil", exception.message)
  end

  def test_should_raise_if_values_is_empty
    exception = assert_raises(LareRound::LareRoundError){
      LareRound.round([],2)
    }
    assert_equal("values must not be empty", exception.message)
  end

  def test_should_raise_if_values_contains_invalid_values
    exception = assert_raises(LareRound::LareRoundError){
      LareRound.round([3.2, 1, "not_a_number", Exception.new, nil],2)
    }
    assert_equal("values contains not numeric values (3)", exception.message)
  end

  def test_should_warn_if_numbers_not_big_decimals
    out, err = capture_io do
      LareRound.round([1.2132, 12.21212, 323.23],2)
    end
    assert_match(/values contains non decimal values, you might loose precision or even get wrong rounding results/, err)
  end

end
