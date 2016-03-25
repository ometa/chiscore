require 'routers/router'
require 'routers/helpers/leaderboard_helper'
require 'chiscore/repository'

module Routers
  class Public < Router
    def update_scores
      ChiScore::Leaderboard.update_scores(ChiScore::Routes.all)
    end

    def get?
      request.request_method == "GET"
    end

    get "/" do
      update_scores
      if admin?
        redirect "/admin"
      else
        routes = ChiScore::Routes.all.reject { |r| r.id =~ /ART/ }
        _erb :public,
          :routes => routes,
          :checkpoints => ChiScore::Checkpoints.all,
          :leaderboards => routes.map {|route|
            [ route, ChiScore::Leaderboard.new(route)]
          }
      end
    end

    get "/:route" do
      update_scores
      begin
        _erb :route_standings,
          :routes => ChiScore::Routes.all,
          :route => ChiScore::Routes.find(params[:route])
      rescue KeyError
        redirect "/public"
      end
    end

    get "/checkpoint/:id" do
      begin
        _erb :public_checkpoint,
          :checkpoint => ChiScore::Checkpoints.find(params[:id])
      rescue KeyError
        redirect "/public"
      end
    end

    get "/checkpoint/:id/times" do
      checkpoint = ChiScore::Checkpoints.find(params[:id])
      ChiScore::Checkins.times_for(checkpoint).to_json
    end

    get "/checkpoints/all" do
      _erb :public_checkpoints, :checkpoints => ChiScore::Checkpoints.all
    end

  end
end
