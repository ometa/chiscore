require 'routers/router'
require 'routers/helpers/auth_helper'
require 'chiscore/repository'

module Routers
  class Admin < Router
    before { require_admin! }

    get "/" do
      if admin?
        ChiScore::Leaderboard.update_scores(ChiScore::Routes.all)
        _erb :admin,
          :checkpoints => @checkpoints,
          :teams => ChiScore::Teams.all,
          :routes => ChiScore::Routes.all
      else
        redirect "/auth"
      end
    end

    get '/start-race' do
      ChiScore::Repository.save_race_start
      redirect "/"
    end

    get "/flags" do
      _erb :flagged_teams, :data => ChiScore::Flags.all_by_checkpoint
    end

    get '/active' do
      _erb :active_teams, :checkpoints => ChiScore::Checkpoints.all
    end
  end
end
