require 'csv'
require 'pp'

require 'chiscore/teams'
require 'chiscore/checkins'
require 'chiscore/checkpoints'
require 'chiscore/routes'
require 'chiscore/logins'
require 'chiscore/repository'
require 'chiscore/repository/redis_strategy'
require 'chiscore/support/data_importer'

ChiScore::Repository.set_strategy(ChiScore::RedisStrategy)
ChiScore::DataImporter.import_for(2017)

module ChiScore
  class DataExporter

    def export
      results = ChiScore::Teams.all.map do |team|
        values_for(team)
      end.compact

      csv_str = CSV.generate do |csv|
        results.each { |row| csv << row }
      end

      puts
      puts
      puts "Delete anything above this line (including this line)"
      puts csv_str
    end

    def values_for(team)
      values = [
        team.id,
        team.name,
        timezone,
        fmt_time(race_start_time)
      ]

      begin
        route = ChiScore::Routes.find(team.route)
      rescue KeyError => e
        return
      end

      route.checkpoints.each do |checkpoint|
        checkin_time = ChiScore::Checkins.time_for(checkpoint, team)
        values << fmt_time(checkin_time)
      end

      team_finish = ChiScore::Checkins.time_for(finish_checkpoint, team)
      total_time = Time.at(team_finish) - race_start_time
      fmt_total = total_time ? fmt_time(Time.at(total_time).utc) : ""

      return values + [fmt_total]
    end

    def timezone
      ENV['TZ']
    end

    def fmt_time(time)
      time ? Time.at(time).strftime("%H:%M:%S") : ""
    end

    def race_start_time
      @_start_time ||= Time.at((ChiScore::Repository.fetch_race_start || 0).to_i)
    end

    def finish_checkpoint
      @_finish_checkpoint ||= ChiScore::Checkpoints.find(6)
    end
  end
end
