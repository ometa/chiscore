require 'chiscore/support/static_collection'

module ChiScore
  class Leaderboard
    class << self
      def update_scores(routes)
        routes.map { |route| update_teams_for(route) }
      end

    private

      def update_teams_for(route)
        route.teams.each do |team|
          team.checkouts,
            team.checkins = ChiScore::Checkins.checkpoint_visits(team)
        end
      end
    end

    attr_accessor :route

    def initialize(route)
      self.class.update_scores([route])
      self.route = route
    end

    def leader_details
      leaders.map do |team|
        [
          team,
          verb(team),
          format(team.last_checkin)
        ]
      end
    end

    def leaders
      route.teams.reject { |team| team.checkins.count.zero? }.sort.take(5)
    end

    private

    def message(team)
      "#{verb(team)} #{team.last_checkpoint.name} at #{format(team.last_checkin)}"
    end

    def verb(team)
      team.at_checkpoint? ? "arrived at" : "departed"
    end

    def format(time)
      Time.at(time).strftime("%I:%M:%S")
    end
  end
end
