require 'rspec'
require 'simplecov'

SimpleCov.start do
  add_filter "/vendor/"
end

$: << Dir.pwd

ENV['RACK_ENV'] = 'test'

# RSpec.configure do |config|
#   config.expect_with(:rspec) { |c| c.syntax = :should }
# end
