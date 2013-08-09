require_relative 'test_helper'
require 'bigdecimal'

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


end
