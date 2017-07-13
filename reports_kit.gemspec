require File.expand_path('../lib/reports_kit/version', __FILE__)

Gem::Specification.new do |s|
  s.authors       = ['Tom Benner']
  s.email         = ['tombenner@gmail.com']
  s.summary       = 'Beautiful, interactive charts for Ruby on Rails'
  s.description   = 'ReportsKit lets you easily create beautiful charts with customizable, interactive filters.'
  s.homepage      = 'https://github.com/tombenner/reports_kit'

  s.files         = `git ls-files`.split($\)
  s.name          = 'reports_kit'
  s.require_paths = ['lib']
  s.version       = ReportsKit::VERSION
  s.license       = 'MIT'

  s.add_dependency 'rails', '>= 3'
  s.add_dependency 'spreadsheet', '>= 1.1'

  s.add_development_dependency 'appraisal'
  s.add_development_dependency 'rspec', '~> 3'
  s.add_development_dependency 'database_cleaner', '~> 1'
  s.add_development_dependency 'factory_girl', '~> 4'
  s.add_development_dependency 'pg', '>= 0.15'
  s.add_development_dependency 'pry', '~> 0'
  s.add_development_dependency 'pry-byebug', '~> 1'
  s.add_development_dependency 'timecop', '~> 0'
end
