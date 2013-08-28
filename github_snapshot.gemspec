# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'github_snapshot/version'

Gem::Specification.new do |spec|
  spec.name          = "github_snapshot"
  spec.version       = GithubSnapshot::VERSION
  spec.authors       = ["Artur Rodrigues" , "Joao Sa"]
  spec.email         = ["arturhoo@gmail.com"]
  spec.description   = %q{Snapshots multiple organizations GitHub repositories, including wikis, and syncs them to Amazon's S3}
  spec.summary       = %q{Snapshots Github repositories}
  spec.homepage      = "https://github.com/innvent/github_snapshot"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "awesome_print"

  spec.add_dependency "github_api", "~> 0.10.2"
end
