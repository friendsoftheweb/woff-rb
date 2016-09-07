lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'woff/version'

Gem::Specification.new do |gem|
  gem.name          = "woff"
  gem.version       = WOFF::VERSION
  gem.authors       = ["Josh Hepworth"]
  gem.licenses      = "MIT"
  gem.email         = ["josh@friendsoftheweb.com"]
  gem.description   = %q{Handles the management and modification of WOFF formatted files.}
  gem.summary       = %q{Reading and modifying binary WOFF files.}
  gem.homepage      = "https://github.com/friendsoftheweb/woff-rb"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.1.0"

  gem.add_dependency "bindata", "~> 2.3"

  gem.add_development_dependency "rake", "~> 11.2.2"
  gem.add_development_dependency "rspec", "~> 3.5.0"
end
