require 'rspec'

$: << Dir.pwd

ENV['RACK_ENV'] = 'test'

# RSpec.configure do |config|
#   config.expect_with(:rspec) { |c| c.syntax = :should }
# end
