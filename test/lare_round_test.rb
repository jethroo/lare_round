# frozen_string_literal: true

require_relative 'test_helper'
require 'bigdecimal'
require 'securerandom'

class LareRoundTest < Minitest::Spec
  def test_has_static_method_round
    assert_equal(true, LareRound.respond_to?(:round))
  end

  def create_big_decimal(precision, digit)
    BigDecimal('0.' + '3' * precision + digit.to_s)
  end

  (1..9).each do |digit|
    (1..23).each do |items|
      (0..10).each do |precision|
        method_name = <<-TESTMETHOD.strip.gsub(/\s+/, '_')
          test #{items} items with last digit of #{digit}
          should sum up to rounded total of BigDecimal items
          with precision of #{precision} if passed as array
        TESTMETHOD
        define_method method_name do
          arr = Array.new(items) { create_big_decimal(precision, digit) }
          rounded_total = arr.reduce(:+).round(precision)
          assert_equal(
            rounded_total,
            LareRound.round(arr, precision).reduce(:+).round(precision)
          )
        end

        method_name = <<-TESTMETHOD.strip.gsub(/\s+/, '_')
          test #{items} rounded items with last digit of #{digit}
          should sum up to rounded total of BigDecimal items
          with precision of #{precision} if passed as hash
        TESTMETHOD
        define_method method_name do
          hash = Hash[
            (1..items).map do |x|
              [x, create_big_decimal(precision, digit)]
            end
          ]
          rounded_total = hash.values.reduce(:+).round(precision)
          assert_equal(
            rounded_total,
            LareRound.round(hash, precision).values.reduce(:+).round(precision)
          )
        end

        method_name = <<-TESTMETHOD.strip.gsub(/\s+/, '_')
          test #{items} rounded items with last digit of #{digit}
          and precision of #{precision}
          if passed as hash should not change order
        TESTMETHOD
        define_method method_name do
          hash = Hash[
            (1..items).map.with_index do |x, i|
              [x, create_big_decimal(precision, digit) + BigDecimal(i)]
            end
          ]
          rounded_hash = LareRound.round(hash.clone, precision)
          hash.keys.each do |key|
            assert((((hash[key] - rounded_hash[key]) * 10**precision).abs < 1))
          end
        end

        method_name = <<-TESTMETHOD.strip.gsub(/\s+/, '_')
          test #{items} rounded negative items with last digit of #{digit}
          should sum up to rounded total of BigDecimal items with precision
          of #{precision} if passed as array
        TESTMETHOD
        define_method method_name do
          arr = Array.new(items) do
            BigDecimal(-1 * create_big_decimal(precision, digit))
          end
          rounded_total = arr.reduce(:+).round(precision)
          assert_equal(
            rounded_total,
            LareRound.round(arr, precision).reduce(:+).round(precision)
          )
        end

        method_name = <<-TESTMETHOD.strip.gsub(/\s+/, '_')
          test #{items} rounded mixed (+/-) items with last digit of #{digit}
          should sum up to rounded total of BigDecimal items with precision
          of #{precision} if passed as array
        TESTMETHOD
        define_method method_name do
          arr = Array.new(items) { create_big_decimal(precision, digit) }
          arr.map! { |i| SecureRandom.random_number(1).even? ? i : -1 * i }
          rounded_total = arr.reduce(:+).round(precision)
          assert_equal(
            rounded_total,
            LareRound.round(arr, precision).reduce(:+).round(precision)
          )
        end
      end
    end
  end

  let(:default_array) { Array.new(3) { BigDecimal('0.1234') } }

  def test_should_raise_if_precision_is_nil
    exception = assert_raises(LareRound::LareRoundError) do
      LareRound.round(default_array, nil)
    end
    assert_equal('precision must not be nil', exception.message)
  end

  def test_should_raise_if_precision_is_less_than_zero
    exception = assert_raises(LareRound::LareRoundError) do
      LareRound.round(default_array, -1)
    end
    assert_equal('precision must be greater or equal to 0', exception.message)
  end

  def test_should_raise_if_precision_is_not_a_number
    exception = assert_raises(LareRound::LareRoundError) do
      LareRound.round(default_array, 'not_a_number')
    end
    assert_equal('precision must be a number', exception.message)
  end

  def test_should_raise_if_values_is_nil
    exception = assert_raises(LareRound::LareRoundError) do
      LareRound.round(nil, 2)
    end
    assert_equal('values must not be nil', exception.message)
  end

  def test_should_raise_if_values_is_empty
    exception = assert_raises(LareRound::LareRoundError) do
      LareRound.round([], 2)
    end
    assert_equal('values must not be empty', exception.message)
  end

  def test_should_raise_if_values_contains_invalid_values
    exception = assert_raises(LareRound::LareRoundError) do
      LareRound.round([3.2, 1, 'not_a_number', Exception.new, nil], 2)
    end
    assert_equal('values contains not numeric values (3)', exception.message)
  end

  def test_should_warn_if_numbers_not_big_decimals
    _out, err = capture_io do
      LareRound.round([1.2132, 12.21212, 323.23], 2)
    end
    assert_match(/you might loose precision/, err)
  end
end
