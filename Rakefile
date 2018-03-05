$: << File.join(File.dirname(__FILE__), "lib")

if ENV['RACK_ENV'] != 'production'
  require 'rspec/core/rake_task'

  desc "Runs the ruby unit test suite"
  task(:spec) { RSpec::Core::RakeTask.new { |t| t.verbose = false }}

  task :default => [:spec]
end

require 'securerandom'

desc "generate the secret key"
task :gen_secrets do
  File.open("./config/secret_key", "w+") { |file| file << SecureRandom.hex(24) + "\n" }
  File.open("./config/admin_key", "w+") { |file| file << SecureRandom.hex(24) + "\n" }
end

# DANGER!
task :redis_flushdb do
  require 'chiscore/repository/redis_strategy'
  redis = ChiScore::RedisStrategy.redis
  redis.flushdb
end

task "export" do
  require 'chiscore/support/data_exporter'
  ChiScore::DataExporter.new.export
end
