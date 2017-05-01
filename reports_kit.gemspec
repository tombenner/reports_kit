require File.expand_path('../lib/reports_kit/version', __FILE__)

Gem::Specification.new do |s|
  s.authors       = ['Tom Benner']
  s.email         = ['tombenner@gmail.com']
  s.description = s.summary = %q{TODO}
  s.homepage      = 'https://github.com/tombenner/reports_kit'

  s.files         = `git ls-files`.split($\)
  s.name          = 'reports_kit'
  s.require_paths = ['lib']
  s.version       = ReportsKit::VERSION
  s.license       = 'MIT'

  s.add_development_dependency 'rspec'
end
