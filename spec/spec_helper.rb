require 'reports_kit'

require 'database_cleaner'
require 'pry'
require 'pry-byebug'
require 'timecop'
require 'support/factory_girl'
require 'support/helpers'

Time.zone = ActiveSupport::TimeZone.new('UTC')
ActiveRecord::Base.default_timezone = :utc

if Gem.loaded_specs.key?('mysql2')
  REPORTS_KIT_DATABASE_ADAPTER = ReportsKit::Reports::Adapters::Mysql
  REPORTS_KIT_DATABASE_TYPE = :mysql
  ActiveRecord::Base.establish_connection(
    adapter: 'mysql2',
    host: ENV['MYSQL_HOST'] || 'localhost',
    database: 'reports_kit_test',
    username: 'root'
  )
else
  REPORTS_KIT_DATABASE_ADAPTER = ReportsKit::Reports::Adapters::Postgresql
  REPORTS_KIT_DATABASE_TYPE = :postgresql
  ActiveRecord::Base.establish_connection(
    adapter: 'postgresql',
    host: ENV['POSTGRESQL_HOST'] || 'localhost',
    database: 'reports_kit_test',
    username: 'postgres'
  )
end
directory = File.dirname(File.absolute_path(__FILE__))
Dir.glob("#{directory}/support/models/*.rb") { |file| require file }
Dir.glob("#{directory}/support/models/**/*.rb") { |file| require file }
Dir.glob("#{directory}/factories/*.rb") { |file| require file }

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
    # To support multi-threaded ActiveRecord queries, we need to use :truncation instead of :transaction.
    DatabaseCleaner.strategy = [:truncation, pre_count: true]
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end

  config.include Helpers
end
