require 'bigdecimal'

module LareRound

  def self.round(values,precision)
    raise LareRoundError.new("precision must not be nil")                   if precision.nil?
    raise LareRoundError.new("precision must be a number")                  unless precision.is_a? Numeric
    raise LareRoundError.new("precision must be greater or equal to 0")     if precision < 0
    raise LareRoundError.new("values must not be nil")                      if values.nil?
    raise LareRoundError.new("values must not be empty")                    if values.empty?
    if values.kind_of?(Array)
      round_array_of_values(values,precision)
    elsif values.kind_of?(Hash)
      rounded_values = round_array_of_values(values.values,precision)
      values.keys.each_with_index do |key,index|
        values[key] = rounded_values[index]
      end
      return values
    end
  end

  # StandardError for dealing with application level errors
  class LareRoundError < StandardError

  end

  private
  def self.round_array_of_values(array_of_values,precision)
    raise LareRoundError.new("array_of_values must be an array")            unless array_of_values.is_a? Array
    number_of_invalid_values = array_of_values.map{|i| i.is_a? Numeric}.reject{|i| i == true}.size
    raise LareRoundError.new("values contains not numeric values (#{number_of_invalid_values})") if number_of_invalid_values > 0
    warn "values contains non decimal values, you might loose precision or even get wrong rounding results" if array_of_values.map{|i| i.is_a? BigDecimal}.reject{|i| i == true}.size > 0

    #prevention of can't omit precision for a Rational
    decimal_shift = BigDecimal.new (10 ** precision.to_i)
    rounded_total = array_of_values.reduce(:+).round(precision) * decimal_shift
    array_of_values = array_of_values.map{|v| ((v.is_a? BigDecimal) ? v : BigDecimal.new(v.to_s))}
    unrounded_values = array_of_values.map{|v| v * decimal_shift }

    # items needed to be rounded down if positiv:
    # 0.7 + 0.7 + 0.7 = ( 2.1 ).round(0) = 2
    # (0.7).round(0) + (0.7).round(0) + (0.7).round(0) = 1 + 1 + 1 = 3
    # elsewise if negative
    rounded_values = array_of_values.map{|v| v < 0 ? v.round(precision, BigDecimal::ROUND_UP) * decimal_shift : v.round(precision, BigDecimal::ROUND_DOWN) * decimal_shift }

    while not rounded_values.reduce(:+) >= rounded_total
      fractions = unrounded_values.zip(rounded_values).map { |x, y| x - y }
      rounded_values[fractions.index(fractions.max)] += 1
    end

    return rounded_values.map{|v| v / decimal_shift }
  end

end
