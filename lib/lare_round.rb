require "lare_round/version"

module LareRound

  def self.round(array_of_values,precision)

    decimal_shift = BigDecimal.new (10 ** precision)
    rounded_total = array_of_values.reduce(:+).round(precision) * decimal_shift

    unrounded_values = array_of_values.map{|v| v * decimal_shift }
    rounded_values = array_of_values.map{|v| v.round(precision, BigDecimal::ROUND_DOWN) * decimal_shift }

    while not rounded_values.reduce(:+) >= rounded_total
      fractions = unrounded_values.zip(rounded_values).map { |x, y| x - y }
      rounded_values[fractions.index(fractions.max)] += 1
    end

    return rounded_values.map{|v| v / decimal_shift }
  end

end
