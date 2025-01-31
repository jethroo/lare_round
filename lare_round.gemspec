# frozen_string_literal: true

require 'English'
lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'lare_round/version'

Gem::Specification.new do |spec|
  spec.required_ruby_version = '>= 3.0.4'

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

  spec.metadata      = { 'rubygems_mfa_required' => 'true' }

  spec.files         = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
end
