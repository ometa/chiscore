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

unless ENV['YEAR']
  puts "YEAR environment variable is required.  e.g. YEAR=2018"
  exit 1
end

ChiScore::Repository.set_strategy(ChiScore::RedisStrategy)
ChiScore::DataImporter.import_for(ENV['YEAR'])

unless ENV['OUTPUT']
  puts "You must supply the OUTPUT environment variable with a value of 'csv' or 'html'"
  exit 1
end

# TODO: when there's no total time for a team, it reports '05:37:54'. It should report 'Did Not Finish'
# TODO: when there's no checkin time for a checkpoint, it reports '12:22:06'. It should report '--'

module ChiScore
  class DataExporter

    def export
      puts
      puts
      puts "Delete anything above this line (including this line)"
      puts format(get_values)
    end

    def get_values
      all = ChiScore::Teams.all.map do |team|
        values_for(team)
      end.compact

      all.sort_by! do |row|
        row.last
      end

      all.map! do |row|
        row.slice!(0..-2)
      end
    end

    def format(results)
      case ENV['OUTPUT']
      when 'csv'
        CSV.generate do |csv|
          results.each { |row| csv << row }
        end
      when 'html'
        results.inject("") do |memo, row|
          memo << "<tr><td>" + row.join("</td><td>") + "</td></tr>\n"
        end
      end
    end

    def values_for(team)
      values = [
        team.id,
        team.name
      ]

      begin
        route = ChiScore::Routes.find(team.route)
      rescue KeyError
        return
      end

      unless ENV['SUMMARY']
        values << timezone
        values << fmt_time(race_start_time)

        route.checkpoints.each do |checkpoint|
          checkin_time = ChiScore::Checkins.time_for(checkpoint, team)
          values << fmt_time(checkin_time)
        end
      end

      team_finish = ChiScore::Checkins.time_for(finish_checkpoint, team)
      total_time = Time.at(team_finish) - race_start_time
      fmt_total = total_time ? fmt_time(Time.at(total_time).utc) : ""

      values + [fmt_total, total_time]
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
