# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'aw_datapipe/version'

Gem::Specification.new do |spec|
  spec.name          = "aw_datapipe"
  spec.version       = AwDatapipe::VERSION
  spec.authors       = ["Piers Chambers"]
  spec.email         = ["piers@varyonic.com"]

  spec.summary       = "Unofficial ruby wrapper for the AWS SDK Data Pipeline API."
  spec.description   = "Unofficial domain specific ruby wrapper for the AWS SDK Data Pipeline API."
  spec.homepage      = "http://github.com/varyonic/aw_datapipe"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end

  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency("activesupport", ">= 3")
  spec.add_dependency("aws-sdk", ['~> 2'])

  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
end
