require 'reports_kit'

require 'database_cleaner'
require 'pry'
require 'pry-byebug'
require 'timecop'
require 'support/factory_girl'
require 'support/helpers'

directory = File.dirname(File.absolute_path(__FILE__))
Dir.glob("#{directory}/factories/*.rb") { |file| require file }

Time.zone = ActiveSupport::TimeZone.new('UTC')
ActiveRecord::Base.default_timezone = :utc

if Gem.loaded_specs.has_key?('mysql2')
  REPORTS_KIT_DATABASE_ADAPTER = ReportsKit::Reports::Adapters::Mysql
  REPORTS_KIT_DATABASE_TYPE = :mysql
  ActiveRecord::Base.establish_connection(
    adapter: 'mysql2',
    host: 'localhost',
    database: 'reports_kit_test',
    username: 'root'
  )
else
  REPORTS_KIT_DATABASE_ADAPTER = ReportsKit::Reports::Adapters::Postgresql
  REPORTS_KIT_DATABASE_TYPE = :postgresql
  ActiveRecord::Base.establish_connection(
    adapter: 'postgresql',
    host: 'localhost',
    database: 'reports_kit_test',
    username: 'postgres'
  )
end
Dir.glob("#{directory}/support/models/*.rb") { |file| require file }
require 'support/config'
require 'support/schema'

RSpec.configure do |config|
  # ## Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = 'random'

  TIMECOP_TIME = Time.utc(2010)
  config.before(:each) do
    Timecop.freeze(TIMECOP_TIME)
  end
  config.after(:each) do
    Timecop.return
  end

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end

  config.include Helpers
end
