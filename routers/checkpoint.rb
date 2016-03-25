require 'routers/router'
require 'routers/helpers/auth_helper'
require 'chiscore/checkpoints'
require 'chiscore/checkins'
require 'chiscore/teams'
require 'chiscore/routes'
require 'chiscore/flags'

module Routers
  class Checkpoint < Router
    before { require_auth! }

    get "/" do
      if checkpoint?
        _erb :checkpoint, {
          :checkpoint => @checkpoint,
          :remaining_team_count => ChiScore::Checkins.remaining_teams(@checkpoint).count
        }
      else
        redirect '/admin'
      end
    end

    get "/all" do
      if checkpoint?
        _erb :all_checkins, :checkins => ChiScore::Checkins.all_for(@checkpoint)
      elsif admin?
        redirect "/admin"
      else
        redirect "/auth"
      end
    end
  end
end
