# frozen_string_literal: true

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'lare_round/version'

Gem::Specification.new do |spec|
  spec.name          = 'lare_round'
  spec.version       = LareRound::VERSION
  spec.authors       = ['Carsten Wirth']
  spec.email         = ['cwirth79@web.de']

  spec.description   = <<-DESCRIPTION
    A collection of BigDecimal items e.g. invoice items can be rounded for
    displaying them in views. Rounding may apply a rounding error to the
    items such as the summed up rounded items will show deviation towards
    an invoice total with summed unrounded items. Which might cause
    confusion for customers and finance departments alike.

    Application of the largest remainder method can help to preserve the
    total sum for fractionated parts thus eliminating this confusion.
  DESCRIPTION

  spec.summary       = 'gem for rounding BigDecimal items by preserving its sum'
  spec.homepage      = ''
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'minitest'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'simplecov'
end
