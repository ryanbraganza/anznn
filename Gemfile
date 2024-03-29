source 'http://rubygems.org'

gem 'rails', '3.1.6'

# Bundle edge Rails instead:
# gem 'rails',     :git => 'git://github.com/rails/rails.git'

#gem 'pg'
gem 'mysql'
# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.1.5'
  gem 'coffee-rails', '~> 3.1.1'
  gem 'uglifier', '>= 1.0.3'
end

gem 'jquery-rails'

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# Use unicorn as the web server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'ruby-debug19', :require => 'ruby-debug'

group :test do
  # Pretty printed test output
  gem 'turn', '~> 0.8.3', :require => false
end

gem "therubyracer"
group :development, :test do
  gem "rspec-rails"
  gem "factory_girl_rails"
  gem "shoulda-matchers"

  # cucumber gems
  gem "cucumber"
  gem "capybara"
  gem "database_cleaner"
  gem "spork", '~> 0.9.0.rc'
  gem "launchy"    # So you can do Then show me the page
  gem "minitest"  # currently breaks without this
  gem "minitest-reporters"
end

group :development do
  gem "rails3-generators"
  gem 'thin'
  gem 'cheat'
end

group :test do
  gem "cucumber-rails", require: false
end

#group :production do
  gem 'google-analytics-rails'
#end

gem "haml"
gem "haml-rails"
gem "tabs_on_rails"
gem "devise"
gem "email_spec", :group => :test
gem "cancan"
gem "capistrano-ext"
gem "capistrano"
gem "capistrano_colors"
gem 'rvm-capistrano'
gem "colorize"
gem "simplecov", ">=0.3.8", :require => false, :group => :test
gem "bootstrap-sass", '~> 1.4.4'
gem "paperclip", "~> 2.0"
gem 'delayed_job_active_record'
gem 'daemons'
gem 'prawn'
gem 'decent_exposure'
gem 'will_paginate', '> 3.0'
gem 'will_paginate-bootstrap'
gem 'whenever', require: false

gem 'jekyll', :require => false

gem 'highline' # This has (up until now) been implicitly included by capistrano