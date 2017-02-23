if RUBY_VERSION =~ /1.9/
  Encoding.default_external = Encoding::UTF_8
  Encoding.default_internal = Encoding::UTF_8
end

source 'https://rubygems.org'
ruby "2.3.1"

gem 'sinatra'
gem 'redis'
gem 'rake'

gem "unicorn"

group :test do
  gem 'rspec'
  gem 'rack-test'
end
