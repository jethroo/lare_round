[![Continuous Integration](https://github.com/jethroo/lare_round/actions/workflows/ci.yml/badge.svg?branch=master)](https://github.com/jethroo/lare_round/actions/workflows/ci.yml)
[![Gem Version](https://img.shields.io/gem/v/lare_round.svg)](https://rubygems.org/gems/lare_round)

# LareRound

LareRound distributes rounding differences across a collection of `BigDecimal` values, such as invoice line items, while preserving the rounded total.

Rounding each item individually can produce a sum that differs from the rounded sum of the original values. This discrepancy can confuse customers and accounting teams. LareRound uses the [**largest remainder method**](https://en.wikipedia.org/wiki/Largest_remainder_method) to adjust individual rounded values so that their sum matches the rounded total.

## Used in production

Since September 4, 2013.

## Example

Suppose an invoice contains three line items stored with four decimal places:

```ruby
items = Array.new(3) { BigDecimal('0.3334') }
# => [0.3334, 0.3334, 0.3334] (BigDecimal values)
```

If you only need to display the invoice total, rounding once is sufficient:

```ruby
items.reduce(:+).round(2).to_f
# => 1.0
```

But what if you need to display each line item separately? The original values are:

| Item | Price |
| --- | ---: |
| Item 1 | 0.3334 |
| Item 2 | 0.3334 |
| Item 3 | 0.3334 |
| **Unrounded total** | **1.0002** |

The obvious approach is to round each item independently to two decimal places:

```ruby
items.map { |item| item.round(2) }.reduce(:+).to_f
# => 0.99
```

However, the displayed items now add up to `0.99`, while the invoice total rounds to `1.00`:

| Item | Displayed price |
| --- | ---: |
| Item 1 | 0.33 |
| Item 2 | 0.33 |
| Item 3 | 0.33 |
| **Sum of displayed items** | **0.99** |
| **Rounded invoice total** | **1.00** |

This discrepancy can confuse customers and undermine their confidence in the invoice.

LareRound distributes the rounding difference across the items so that the displayed values add up to the rounded invoice total:

```ruby
rounded_items = LareRound.round(items, 2)
rounded_items.map(&:to_f)
# => [0.34, 0.33, 0.33]

rounded_items.reduce(:+).to_f
# => 1.0
```

The largest remainder method starts with values rounded down to the required precision, then allocates the remaining smallest units to items with the largest fractional remainders until the target total is reached. In this example, each item starts at `0.33`, and one item receives an additional `0.01`.

| Item | Displayed price |
| --- | ---: |
| Item 1 | 0.34 |
| Item 2 | 0.33 |
| Item 3 | 0.33 |
| **Total** | **1.00** |

LareRound supports both `Array` and `Hash` collections. Here is the equivalent example using a hash:

```ruby
items_by_id = (1..3).to_h { |id| [id, BigDecimal('0.3334')] }
rounded_by_id = LareRound.round(items_by_id, 2)
rounded_by_id.transform_values(&:to_f)
# => {1 => 0.34, 2 => 0.33, 3 => 0.33}

rounded_by_id.values.reduce(:+).to_f
# => 1.0
```

## Open issues / Features

- Support configurable rounding behavior for individual items, such as always rounding tax amounts up.

For example, a tax-specific rounding rule could produce a different result:

| Item | Unrounded price | LareRound | Financial rounding |
| --- | ---: | ---: | ---: |
| Item | 10.000 | 10.00 | 10.00 |
| Tax (8.23%) | 0.823 | 0.82 | 0.83 |
| **Total** | **10.823** | **10.82** | **10.83** |

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'lare_round', '~> 1.0.1'
```

Then run:

```bash
bundle install
```

## Tests

After installing the dependencies, run:

```bash
rake test
```

## Console

To start an interactive Ruby shell (IRB), run:

```bash
bin/console
```

## Contributing

1. Fork the repository.
2. Create a feature branch (`git checkout -b my-new-feature`).
3. Commit your changes (`git commit -am 'Add a new feature'`).
4. Push your branch (`git push origin my-new-feature`).
5. Open a pull request.

## License

Released under the MIT License.

## Authors / Contributors

- [Blacklane GmbH](https://www.blacklane.com)
- [Carsten Wirth](https://github.com/jethroo)
