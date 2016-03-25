require 'rack'

require 'routers/router'
require 'routers/api/checkins'
require 'routers/api/flags'
require 'routers/checkpoint'
require 'routers/admin'
require 'routers/auth'
require 'routers/public'

require 'chiscore/teams'
require 'chiscore/checkpoints'
require 'chiscore/checkins'
require 'chiscore/auth'
require 'chiscore/leaderboard'
require 'chiscore/repository/redis_strategy'

require 'chiscore/support/data_importer'
require 'chiscore/repository/dev_strategy'

set :sessions, true

ChiScore::Repository.set_strategy(ChiScore::RedisStrategy)
ChiScore::DataImporter.import_for(2016)

ChiScore::App = Rack::Builder.new do
  use Rack::Session::Cookie, :secret => ChiScore::Auth.secret_key

  map("/api/checkins")  { run Routers::Api::Checkins }
  map("/api/flags")     { run Routers::Api::Flags }
  map("/auth")          { run Routers::Auth }
  map("/")              { run Routers::Checkpoint }
  map("/admin")         { run Routers::Admin }
  map("/public")        { run Routers::Public }
end
