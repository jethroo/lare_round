require 'bigdecimal'

module LareRound

  def self.round(values, precision)
    handle_input_errors(values, precision)
    process(values, precision)
  end

  # StandardError for dealing with application level errors
  class LareRoundError < StandardError; end

  private

  def self.process(values, precision)
    values.kind_of?(Hash) ? process_hash(values, precision) : round_array_of_values(values, precision)
  end

  def self.process_hash(values, precision)
    rounded_values = round_array_of_values(values.values, precision)
    values.tap do |values| 
      values.keys.each_with_index do |key, index|
        values[key] = rounded_values[index]
      end
    end
  end

  def self.handle_input_errors(values, precision)
    # although it is the senders responsibility to ensure that correct messages are sent to this module
    # it might not be quite obvious so i provide some help here with errors if input is invalid

    raise LareRoundError.new("precision must not be nil")                   if precision.nil?
    raise LareRoundError.new("precision must be a number")                  unless precision.is_a? Numeric
    raise LareRoundError.new("precision must be greater or equal to 0")     if precision < 0
    raise LareRoundError.new("values must not be nil")                      if values.nil?
    raise LareRoundError.new("values must not be empty")                    if values.empty?

    array_of_values = values.kind_of?(Hash) ? values.values : values
    raise LareRoundError.new("array_of_values must be an array") unless array_of_values.is_a? Array 

    number_of_invalid_values = array_of_values.map{|i| i.is_a? Numeric}.reject{|i| i == true}.size
    raise LareRoundError.new("values contains not numeric values (#{number_of_invalid_values})") if number_of_invalid_values > 0

    warning = "values contains non decimal values, you might loose precision or even get wrong rounding results"
    warn warning if array_of_values.map{|i| i.is_a? BigDecimal}.reject{|i| i == true}.size > 0
  end

  Struct.new(
    "IntermediaryResults", 
    :decimal_shift, 
    :rounded_total, 
    :array_of_values, 
    :unrounded_values, 
    :precision,
    :rounded_values
  )

  def self.round_array_of_values(array_of_values, precision)
    mrc = Struct::IntermediaryResults.new
    mrc.precision = precision
    #prevention of can't omit precision for a Rational
    mrc.decimal_shift = BigDecimal.new (10 ** precision.to_i)
    mrc.rounded_total = array_of_values.reduce(:+).round(precision) * mrc.decimal_shift
    mrc.array_of_values = array_of_values.map{|v| ((v.is_a? BigDecimal) ? v : BigDecimal.new(v.to_s))}
    mrc.unrounded_values = array_of_values.map{|v| v * mrc.decimal_shift }

    largest_remainder_method(mrc)

    return mrc.rounded_values
  end

  def self.largest_remainder_method(mrc)
    mrc.rounded_values = mrc.array_of_values.map{|v| largest_remainder_round(v, mrc) }

    while not mrc.rounded_values.reduce(:+) >= mrc.rounded_total
      fractions = mrc.unrounded_values.zip(mrc.rounded_values).map { |x, y| x - y }
      mrc.rounded_values[fractions.index(fractions.max)] += 1
    end

    mrc.rounded_values.map!{|v| v / mrc.decimal_shift }
  end

  def self.largest_remainder_round(v, mrc)
    # items needed to be rounded down if positiv:
    # 0.7 + 0.7 + 0.7 = ( 2.1 ).round(0) = 2
    # (0.7).round(0) + (0.7).round(0) + (0.7).round(0) = 1 + 1 + 1 = 3
    # elsewise if negative
    rounding_strategy = if v < 0
      BigDecimal::ROUND_UP
    else
      BigDecimal::ROUND_DOWN
    end
    v.round(mrc.precision, rounding_strategy ) * mrc.decimal_shift
  end
end
