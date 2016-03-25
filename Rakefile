$: << File.join(File.dirname(__FILE__), "lib")

require 'rspec/core/rake_task'
require 'securerandom'

task :default => [:spec]

desc "Runs the ruby unit test suite"
task(:spec) { RSpec::Core::RakeTask.new { |t| t.verbose = false }}

desc "generate the secret key"
task :gen_secrets do
  File.open("./config/secret_key", "w+") { |file| file << SecureRandom.hex(24) + "\n" }
  File.open("./config/admin_key", "w+") { |file| file << SecureRandom.hex(24) + "\n" }
end
