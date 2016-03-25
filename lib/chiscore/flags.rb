module ChiScore
  class Flags
    class << self
      def flag_team(checkpoint, team)
        Repository.flag!(checkpoint, team)
      end

      def all_by_checkpoint
        Checkpoints.all.inject({}) do |acc, checkpoint|
          Repository.find_flags(checkpoint).map do |team_id, _|
            acc[checkpoint] ||= {}
            acc[checkpoint][team_id] = Teams.find(team_id)
          end

          acc
        end
      end
    end
  end
end
