require 'chiscore/teams'
require 'chiscore/repository'

module ChiScore
  class Checkins

    LockedCheckinAttempt = Class.new(StandardError)
    EarlyCheckout        = Class.new(StandardError)
    IllegalDestroy       = Class.new(StandardError)

    class << self
      def checkin(checkpoint, team, *args)
        raise LockedCheckinAttempt if locked?(team)
        Repository.check_in!(checkpoint.id, team.id)
        Repository.check_out!(checkpoint.id, team.id) if checkpoint.role == "endpoint"
      end

      def remaining_teams(checkpoint)
        checked_in_ids = checkins(checkpoint).keys
        checkpoint.all_teams.reject { |team| checked_in_ids.include?(team.id) }
      end

      def locked?(team)
        Repository.lock(team.id) >= 0
      end

      def active(checkpoint)
        Repository.active_for(checkpoint.id)
      end

      def times_for(checkpoint)
        active(checkpoint).map do |team_id|
          team = Teams.find(team_id)
          {
            :time => Repository.time_for(checkpoint.id, team_id),
            :team => { :name => team.name, :id => team_id }
          }
        end.sort { |a, b| a[:time] <=> b[:time] }
      end

      def checkout(checkpoint, team, admin)
        raise EarlyCheckout if !admin && early?(team)
        Repository.check_out!(checkpoint.id, team.id)
      end

      def checkpoint_visits(team)
        [
          Repository.team_checkouts(team.id),
          Repository.team_checkins(team.id)
        ]
      end

      def early?(team)
        time = Repository.lock(team.id)
        time != -2 && time >= 60
      end

      def all_for(checkpoint)
        out_times = self.checkouts(checkpoint)
        checkins(checkpoint).map do |team_id, in_time|
          {
            :times => [ in_time, out_times[team_id]],
            :team  => { :name => Teams.find(team_id).name, :id => team_id }
          }
        end
      end

      def time_for(checkpoint, team)
        Repository.team_checkin(checkpoint.id, team.id)
      end

      def checkout_for(checkpoint, team)
        Repository.team_checkout(checkpoint.id, team.id)
      end

      def checkins(checkpoint)
        Repository.checkins_for(checkpoint.id)
      end

      def checkouts(checkpoint)
        Repository.checkouts_for(checkpoint.id)
      end

      def destroy_checkin(checkpoint, team, admin)
        if Repository.lock(team.id) <= 1300 && !admin
          raise IllegalDestroy
        end

        Repository.destroy_checkin!(checkpoint.id, team.id)
      end
    end
  end
end
