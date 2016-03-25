require 'routers/router'

module Routers
  module Api
    class Flags < Router
      attr_reader :checkpoint, :team

      def set_checkpoint
        @checkpoint = ChiScore::Checkpoints.find(session['checkpoint-id'])
      rescue KeyError => e
        halt(404)
      end

      def set_team
        @team = ChiScore::Teams.find(params['team_id']) if params['team_id']
      rescue KeyError => e
        halt(404)
      end

      before %r{.*} do
        set_checkpoint
        set_team
      end

      post "/flag_team" do
        ChiScore::Flags.flag_team(checkpoint, team)
      end
    end
  end
end
