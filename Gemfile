source 'http://rubygems.org'

gem 'rails', '3.1.3'

# Bundle edge Rails instead:
# gem 'rails',     :git => 'git://github.com/rails/rails.git'

gem 'pg'

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
  gem "shoulda"

  # cucumber gems
  gem "cucumber"
  gem "cucumber-rails"
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

gem "haml"
gem "haml-rails"
gem "tabs_on_rails"
gem "devise"
gem "email_spec", :group => :test
gem "cancan"
gem "capistrano-ext"
gem "capistrano"
gem "capistrano_colors"
gem "colorize"
gem "metrical"
gem "simplecov", ">=0.3.8", :require => false, :group => :test

