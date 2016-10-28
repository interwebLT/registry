source 'https://rubygems.org'

gem 'rails', '4.2.6'

gem 'rails-api'
gem 'pg'
gem 'bcrypt-ruby',  '~> 3.1.2'
gem 'unicorn'

group :development, :test do
  gem 'rspec-rails'
end

group :test do
  gem 'minitest-spec-rails'
  gem 'webmock'
  gem 'cucumber-rails', require: false
  gem 'database_cleaner'
  gem 'factory_girl_rails'
  gem 'timecop'
  gem 'json_expressions'
end

group :development do
  gem 'capistrano'
  gem 'capistrano-rbenv'
  gem 'capistrano-bundler'
  gem 'capistrano-rails'
  gem 'capistrano3-unicorn'
  gem 'capistrano-sidekiq', '0.5.2'
  gem 'letter_opener'
end

gem 'active_model_serializers', '~> 0.8.2'
gem 'will_paginate', '~> 3.1.0'
gem 'rest-client'
gem 'exception_notification'
gem 'money-rails'
gem 'whenever'
gem 'httparty'
gem 'sidekiq'
gem 'epp-client',           github: 'dotph/epp-client'