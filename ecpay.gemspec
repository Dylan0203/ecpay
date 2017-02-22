# coding: utf-8
# frozen_string_literal: true
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ecpay/version'

Gem::Specification.new do |spec|
  spec.name          = 'ecpay_client'
  spec.version       = Ecpay::VERSION
  spec.authors       = ['Jian Weihang']
  spec.email         = ['tonytonyjan@gmail.com']
  spec.summary       = '綠界（Ecpay）API 包裝'
  spec.description   = '綠界（Ecpay）API 包裝'
  spec.homepage      = 'https://github.com/CalvertYang/ecpay'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.11'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'sinatra'
end
