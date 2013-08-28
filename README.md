# LareRound

A collection of BigDecimal items e.g. invoice items can be rounded for displaying them in views. Rounding may apply a rounding error to the items such as the summed up rounded items will show deviation towards an invoice total with summed unrounded items. Which might cause confusion for customers and finance departments alike. Application of the largest remainder method can help to preserve the total sum for rounded parts thus eliminating this confusion.

## Build status
[![Build Status](https://secure.travis-ci.org/jethroo/lare_round.png)](http://travis-ci.org/jethroo/lare_round)


## Work in Progess

The gem status is still 'work in progress', it will be released until it satisfies my (and hopefully your) expectations.

## Example

say we have an array of 3 invoice items which are stored in the database and your invoice calculations are precise to the 4th position after the decimal point:

```ruby
Array.new(3){BigDecimal.new('0.3334')}
#  => [#<BigDecimal:c75a38,'0.3334E0',9(18)>, #<BigDecimal:c759c0,'0.3334E0',9(18)>, #<BigDecimal:c75920,'0.3334E0',9(18)>]
```
say you have an invoice which is rendered as pdf which only needs to display the total you are fine, because you only
have to round once for displaying a customer friendly price:

```ruby
Array.new(3){BigDecimal.new('0.3334')}.reduce(:+).round(2).to_f
# => 1.0
```

But what if you need to dispay each item separately? Each item of the invoice has to be displayed in a customer friendly way.

Item | Price
 --- | ---
 item 1 | 0.3334
 item 2 | 0.3334
 item 3 | 0.3334
 **Total** | **1.0002**


So the most likely aproach is to simply round each item by itself, so the customer isn't bothered with 34/10000 €-Cents. Simple at it is its not quite what you want:

```ruby
Array.new(3){BigDecimal.new('0.3334')}.map{|i| i.round(2)}.reduce(:+).to_f
# => 0.99
```

Item | Price
 --- | ---
 item 1 | 0.33
 item 2 | 0.33
 item 3 | 0.33
 **Total** | **1.00**

Now you have the customer bothering about why there is a difference between the invoice total and the invoice items sum. Which may lead in mistrust ("Hey! These guys can't even do math. I'll keep my money.") or all kinds of related confusions.

This gem helps to distribute the rounding error amongst the items to preserve the total:
```ruby
a =  Array.new(3){BigDecimal.new('0.3334')}
# => [#<BigDecimal:887b6c8,'0.3334E0',9(18)>, #<BigDecimal:887b600,'0.3334E0',9(18)>, #<BigDecimal:887b4c0,'0.3334E0',9(18)>]
a = LareRound.round(a,2)
# => [#<BigDecimal:8867330,'0.34E0',9(36)>, #<BigDecimal:8867290,'0.33E0',9(36)>, #<BigDecimal:88671f0,'0.33E0',9(36)>]
a.reduce(:+).to_f
# => 1.0
```

This is accomplish by utilizing the largest remainder method. Which checks for the items with the largest rounding error and increasing them iteratively as long as the sums do not match. Regarding the before mentioned expample each item
is rounded down to 0.33 and then the algorithm adds 0.01 to one item thus making the sums equal.

Item | Price
 --- | ---
 item 1 | 0.34
 item 2 | 0.33
 item 3 | 0.33
 **Total** | **1.00**

LareRound supports *Array* and *Hash* as collection types. As usage of array was shown above here comes the hash example:

```ruby
hash = Hash[(1..3).map.with_index{|x,i|[x,BigDecimal.new('0.3334')]}]
# => {1=>#<BigDecimal:26ac7d0,'0.3334E0',9(18)>, 2=>#<BigDecimal:26ac730,'0.3334E0',9(18)>, 3=>#<BigDecimal:26ac690,'0.3334E0',9(18)>}
LareRound.round(hash,2)
# => {1=>#<BigDecimal:26b9318,'0.34E0',9(36)>, 2=>#<BigDecimal:26b9250,'0.33E0',9(36)>, 3=>#<BigDecimal:26b91b0,'0.33E0',9(36)>}
LareRound.round(hash,2).values.reduce(:+).to_f
#=> 1.0
```

## Open Issues / Features

  * support specific type of rounding behavior for single items such as always rounding up in the case of taxes

Item (unrounded)| Price (unrounded) | LareRound | Financial
 --- | --- | --- | ---
 item | 10.000 | 10.00 | 10.00
 tax ( 8.23%) | 0.823 | 0.82 | 0.83
 **Total** | **10.823** | **10.82** | **10.83**

  * release as gem

## Installation

Add this line to your application's Gemfile:

    gem 'lare_round', :git => "git://github.com/jethroo/lare_round.git"

And then execute:

    $ bundle

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License
Hereby released under MIT license.

## Authors/Contributors

- [BlackLane GmbH](http://www.blacklane.com "Blacklane")
- [Carsten Wirth](http://github.com/jethroo)
