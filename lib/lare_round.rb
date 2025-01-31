# frozen_string_literal: true

require 'bigdecimal'

# module providing the entry point to the rounding logic
module LareRound
  def self.round(values, precision)
    # although it is the senders responsibility to ensure that correct messages
    # are sent to this module it might not be quite obvious so i provide some
    # help here with errors if input is invalid
    array_of_values = values.is_a?(Hash) ? values.values : values
    handle_value_errors(array_of_values)
    handle_precision_errors(precision)

    process(values, precision)
  end

  # StandardError for dealing with application level errors
  class LareRoundError < StandardError; end

  class << self
    private

    def process(values, precision)
      if values.is_a? Hash
        process_hash(values, precision)
      else
        round_array_of_values(values, precision)
      end
    end

    def process_hash(values, precision)
      rounded_values = round_array_of_values(values.values, precision)
      values.tap do |hash|
        hash.keys.each_with_index do |key, index|
          hash[key] = rounded_values[index]
        end
      end
    end

    def handle_value_errors(values)
      raise LareRoundError, 'values must not be nil' if values.nil?
      raise LareRoundError, 'values must not be empty' if values.empty?
      raise LareRoundError, 'values must be an array' unless values.is_a? Array

      numbers_invalid = values.map { |i| i.is_a? Numeric }
                              .reject { |i| i == true }.size
      if numbers_invalid.positive?
        error = <<-ERROR.strip.gsub(/\s+/, ' ')
          values contains not numeric values (#{numbers_invalid})
        ERROR
        raise LareRoundError, error
      end

      return if values.map { |i| i.is_a? BigDecimal }.reject { |i| i == true }.empty?

      warn <<-WARNING.strip.gsub(/\s+/, ' ')
        values contains non decimal values,
        you might loose precision or even get wrong rounding results
      WARNING
    end

    def handle_precision_errors(precision)
      raise LareRoundError, 'precision must not be nil' if precision.nil?
      raise LareRoundError, 'precision must be a number' unless precision.is_a?(Numeric)
      raise LareRoundError, 'precision must be greater or equal to 0' if precision.negative?
    end

    Struct.new(
      'IntermediaryResults',
      :decimal_shift,
      :rounded_total,
      :array_of_values,
      :unrounded_values,
      :precision,
      :rounded_values
    )

    def round_array_of_values(array_of_values, precision)
      mrc = Struct::IntermediaryResults.new
      mrc.precision = precision
      mrc.decimal_shift = BigDecimal(10**precision.to_i)
      mrc.rounded_total = array_of_values.reduce(:+)
                                         .round(precision) * mrc.decimal_shift
      mrc.array_of_values = array_of_values.map do |v|
        v.is_a?(BigDecimal) ? v : BigDecimal(v.to_s)
      end
      mrc.unrounded_values = array_of_values.map { |v| v * mrc.decimal_shift }

      largest_remainder_method(mrc)

      mrc.rounded_values
    end

    def largest_remainder_method(mrc)
      mrc.rounded_values = mrc.array_of_values.map do |v|
        largest_remainder_round(v, mrc)
      end

      until mrc.rounded_values.reduce(:+) >= mrc.rounded_total
        fractions = mrc.unrounded_values.zip(mrc.rounded_values).map do |x, y|
          x - y
        end
        mrc.rounded_values[fractions.index(fractions.max)] += 1
      end

      mrc.rounded_values.map! { |v| v / mrc.decimal_shift }
    end

    def largest_remainder_round(value, mrc)
      # items needed to be rounded down if positiv:
      # 0.7 + 0.7 + 0.7 = ( 2.1 ).round(0) = 2
      # (0.7).round(0) + (0.7).round(0) + (0.7).round(0) = 1 + 1 + 1 = 3
      # elsewise if negative
      rounding_strategy = if value.negative?
                            BigDecimal::ROUND_UP
                          else
                            BigDecimal::ROUND_DOWN
                          end
      value.round(mrc.precision, rounding_strategy) * mrc.decimal_shift
    end
  end
end
