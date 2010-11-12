# -*- encoding: utf-8 -*-
require File.expand_path("../lib/rack/hammer_version", __FILE__)

Gem::Specification.new do |s|
  s.name        = "rack-hammer"
  s.version     = Rack::HammerVersion
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Paul Bowsher']
  s.email       = ['paul.bowsher@gmail.com']
  s.homepage    = "http://rubygems.org/gems/rack-hammer"
  s.summary     = "Simple single-path Rack profiling"
  s.description = "Hammer a path on your Rack app and get benchmarks and optional profiling"

  s.required_rubygems_version = ">= 1.3.6"
  s.rubyforge_project         = "rack-hammer"

  s.add_development_dependency "bundler", ">= 1.0.0"
  s.add_dependency "ruby-prof", "~> 0.9.2"

  s.files        = `git ls-files`.split("\n")
  s.executables  = `git ls-files`.split("\n").map{|f| f =~ /^bin\/(.*)/ ? $1 : nil}.compact
  s.require_path = 'lib'
end
