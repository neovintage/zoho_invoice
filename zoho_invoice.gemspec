# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'zoho_invoice/version'

Gem::Specification.new do |gem|
  gem.name          = "zoho_invoice"
  gem.version       = ZohoInvoice::VERSION
  gem.authors       = ["Rimas Silkaitis"]
  gem.email         = ["neovintage@gmail.com"]
  gem.summary       = %q{Zoho Invoice API}
  gem.description   = %q{Ruby wrapper for the Zoho Invoice API.  Documentation for the Zoho Invoice API can be found at http://zoho.com}
  gem.homepage      = "https://github.com/neovintage/zoho_invoice"

  gem.required_ruby_version     = ">= 1.9.3"
  gem.required_rubygems_version = ">= 1.3.6"

  gem.add_development_dependency "rake"
  gem.add_development_dependency "webmock"

  gem.add_runtime_dependency "faraday", ">= 0.8.0"
  gem.add_runtime_dependency "faraday-middleware", ">= 0.8.7"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end
