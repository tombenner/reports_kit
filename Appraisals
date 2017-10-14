appraise 'rails_4_mysql' do
  gem 'mysql2'
  gem 'rails', '4.2.10'
end

appraise 'rails_4_postgresql' do
  gem 'pg'
  gem 'rails', '4.2.10'
end

appraise 'rails_5_mysql' do
  gem 'mysql2'
  gem 'rails', '5.1.3'
end

appraise 'rails_5_postgresql' do
  gem 'pg'
  gem 'rails', '5.1.3'
end

# Rails 5.1.4 introduced a bug that generates invalid SQL when using distinct, group, limit and count. This should be resolved in 5.1.5,
# but we'll need to specifically test against 5.1.4 to prevent this bug from impacting ReportsKit when Rails 5.1.4 is being used.
# See https://github.com/tombenner/reports_kit/issues/6
appraise 'rails_5.1.4_postgresql' do
  gem 'pg'
  gem 'rails', '5.1.4'
end
