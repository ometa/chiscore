require 'chiscore/repository/redis_strategy'
require 'csv'

module ChiScore
  class DataImporter
    class << self
      def import_for(year)
        import_routes(year)
        import_checkpoints(year)
        import_logins(year)
        import_teams(year)
      end

      private

      def import_routes(year)
        routes = fetch_from_csv(year, :routes) do |row|
          ChiScore::Route.new(row[0], [row[1], row[2], row[3], row[4], row[5], row[6]])
        end
        ChiScore::Routes.save(routes)
      end

      def import_checkpoints(year)
        checkpoints = fetch_from_csv(year, :checkpoints) do |row|
          ChiScore::Checkpoint.new(row[0].to_i, row[1])
        end
        ChiScore::Checkpoints.save(checkpoints)
      end

      def import_logins(year)
        logins = fetch_from_csv(year, :logins) do |row|
          ChiScore::Login.new(row[0].to_i, row[1], row[2], row[3].to_i)
        end
        ChiScore::Logins.save(logins)
      end

      def import_teams(year)
        teams = fetch_from_csv(year, :teams) do |row|
          ChiScore::Team.new(:id => row[0].to_i, :route => row[1], :name => row[2])
        end
        ChiScore::Teams.save(teams)
      end

      def fetch_from_csv(year, type)
        rows = []
        CSV.foreach("config/data/#{year}/#{type}.csv", encoding: "UTF-8") do |row|
          rows << yield(row)
        end
        rows
      end
    end
  end
end
