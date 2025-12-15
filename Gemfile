source "https://rubygems.org"

ruby "3.4.4"
gem "rails", "~> 7.1.6"
gem "pg", "~> 1.1"
gem "puma", ">= 5.0"
gem "tzinfo-data", platforms: %i[ windows jruby ]
gem "bootsnap", require: false
group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri windows ]
end

group :development do
  gem 'rspec-rails'
  gem 'factory_bot_rails'
  gem 'faker', '~> 3.3'
  gem 'shoulda-matchers'
  gem 'database_cleaner-active_record'
end

gem 'devise'
gem 'devise_token_auth'
gem 'rack-cors'
gem 'httparty'
gem 'cpf_cnpj'
gem 'figaro'
gem 'geocoder'
gem 'pagy'
gem 'pundit'
gem 'dotenv-rails', groups: [:development, :test]
