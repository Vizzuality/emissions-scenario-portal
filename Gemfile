source 'https://rubygems.org'

ruby '2.5.0'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.1.4'

gem 'sprockets', '~> 3.7.2'

gem 'pg', '~> 0.21.0'
gem 'puma'
gem 'sass-rails'
gem 'uglifier'
gem 'coffee-rails'

gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'turbolinks'
gem 'jbuilder'

gem 'dotenv-rails' # required by Devise

gem 'active_model_serializers'
gem 'api-pagination'
gem 'kaminari'
gem 'activerecord-import'
gem 'appsignal'
gem 'aws-sdk', '~> 3'
gem 'charlock_holmes', '~> 0.7.6'
gem 'devise'
gem 'devise_invitable'
gem 'paperclip'
gem 'pg_search'
gem 'pundit'
gem 'rubyzip'
gem 'scenic'
gem 'sidekiq'
gem 'sparkpost_rails'

group :development, :test do
  gem 'byebug', platform: :mri
  gem 'rspec-rails'
  gem 'rspec-collection_matchers'
  gem 'rails-controller-testing'
  gem 'factory_bot_rails'
  gem 'pry-byebug'
  gem 'pry-rails'
end

group :development do
  gem 'web-console'
  gem 'listen'
  gem 'spring'
  gem 'spring-watcher-listen'
  gem 'rubocop', require: false
  gem 'letter_opener'
end

group :test do
  gem 'simplecov', require: false
  gem 'faker'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

source 'https://rails-assets.org' do
  gem 'rails-assets-underscore'
  gem 'rails-assets-backbone'
  gem 'rails-assets-URIjs'
  gem 'rails-assets-select2'
  gem 'rails-assets-tether'
  gem 'rails-assets-drop'
  gem 'rails-assets-tether-tooltip'
end
