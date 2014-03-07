source 'https://rubygems.org'

ruby "2.0.0"                        # ruby version (used by heroku and rvm)

gem 'rails', '4.0.2'
gem 'puma'                          # faster app server
gem 'foreman'                       # process supervision
gem 'pg'                            # postgresql

gem 'coffee-rails', '~> 4.0.0'      # coffeescript
gem 'uglifier', '>= 1.3.0'          # minify
gem 'jquery-rails'                  # jquery
gem 'underscore-rails'              # underscore
gem 'sass-rails', '~> 4.0.0'        # scss support
gem 'bourbon'                       # sass mixins and utilities
gem 'compass-rails'                 # sass mixins and sprites generation
gem 'oily_png'                      # faster png sprite generation for compass
gem 'font-awesome-sass'             # font with svg icons
gem 'tinymce-rails'                 # tinymce wysiwyg editor
gem 'tinymce-rails-langs'           # tinymce language pack

# gem 'turbolinks'                  # speed page loading

gem 'sorcery'                       # authentication
gem 'simple_form'                   # improved forms builder
gem 'sidekiq'                       # background jobs
gem 'http_accept_language'          # get locale from http headers

group :doc do
  gem 'sdoc', :require => false
end

group :development do
  gem 'better_errors'               # better error page, and shell session when crash
  gem 'binding_of_caller', '0.7.1'  # used by better_errors
  gem 'clean_logger'                # silence assets logging
  gem 'letter_opener'               # preview email in the browser
  gem 'letter_opener_web'           # web ui for letter_opener
end

group :development, :test do
  gem 'rspec-rails', '~> 2.0'       # BDD
  gem 'pry'                         # better shell sessions and debug tool
  gem 'pry-rails'                   # use pry as rails console
  gem 'konacha'                     # js tests with mocha + chai
end

group :test do
  gem 'shoulda-matchers'            # extra matchers for rspec
  gem 'factory_girl_rails'          # mock objects
  gem 'capybara'                    # acceptance tests
  gem 'poltergeist'                 # phantomjs driver
  gem 'ejs'                         # js templating for js test fixtures
  gem 'database_cleaner'            # improved database cleaning for tests
  gem 'simplecov', '~> 0.7.1', require: false   # coverage report
end
