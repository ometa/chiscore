require 'routers/router'

module Routers
  module Api
    class Checkins < Router
      attr_reader :checkpoint, :team

      def set_checkpoint
        checkpoint_id = admin? ? params["checkpoint"] : session['checkpoint-id']
        @checkpoint = ChiScore::Checkpoints.find(checkpoint_id)
      rescue KeyError => e
        halt(404)
      end

      def set_team
        @team = ChiScore::Teams.find(params['team_id']) if params['team_id']
      rescue KeyError => e
        halt(404)
      end

      before %r{destroy|checkin|checkout|all|/} do
        set_checkpoint
      end

      before %r{destroy|checkin|checkout} do
        set_team
      end

      post "/" do
        ChiScore::Checkins.times_for(checkpoint).to_json
      end

      get "/" do
        ChiScore::Checkins.times_for(checkpoint).to_json
      end

      post "/checkin" do
        begin
          ChiScore::Checkins.checkin(checkpoint, team)
          {
            :success => true,
            :team => { :id => team.id, :name => team.name },
            :time => 1500
          }.to_json
        rescue ChiScore::Checkins::LockedCheckinAttempt
          active_checkpoint = ChiScore::Checkpoints.all.find { |checkpoint|
            ChiScore::Checkins.active(checkpoint).include?(team.id.to_s)
          }

          { :success => false,
            :checkpoint => { :id => active_checkpoint.id.to_s,
                             :name => active_checkpoint.name
                            },
            :time => ChiScore::Repository.time_for(active_checkpoint.id, team.id)
          }.to_json
        end
      end

      post '/destroy' do
        begin
        ChiScore::Checkins.destroy_checkin(checkpoint, team, admin?)
          { :destroyed => true,
             :team => { :id => team.id, :name => team.name}
          }.to_json
        rescue ChiScore::Checkins::IllegalDestroy
          { :destroyed => false }.to_json
        end
      end

      post "/checkout" do
        begin
          ChiScore::Checkins.checkout(checkpoint, team, admin?)
          {
            :success => true,
            :team => { :id => team.id, :name => team.name }
          }.to_json
        rescue ChiScore::Checkins::EarlyCheckout
          { :success => false }.to_json
        end
      end

      get "/all" do
        ChiScore::Checkins.all_for(checkpoint).to_json
      end
    end
  end
end
