require 'csv'

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

module ChiScore
  class DataExporter

    def export
      puts format(timing_data)
    end

    def timing_data
      all = ChiScore::Teams.all.map do |team|
        values_for(team)
      end.compact

      all.sort_by! do |row|
        row.last
      end
    end

    def format(results)
      case ENV['OUTPUT']
      when 'csv'
        CSV.generate(write_headers: true, headers: headers) do |csv|
          results.each { |row| csv << row }
        end
      when 'html'
        html = "<table>\n<tr><th>" + headers.join("</th><th>") + "</th></tr>\n"
        results.inject(html) do |memo, row|
          memo << "<tr><td>" + row.join("</td><td>") + "</td></tr>\n"
        end + "</table>\n"
      end
    end

    def headers
      values = ["id", "name"]

      unless ENV['SUMMARY']
        ChiScore::Checkpoints.all.size.times do |i|
          values << "checkin_#{i}"
        end
      end

      values + ["time", "time_in_seconds"]
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

      finish_time = ChiScore::Checkins.time_for(finish_checkpoint, team)
      time_in_seconds = finish_time ? Time.at(finish_time) - race_start_time : 0
      time = fmt_time(Time.at(time_in_seconds).utc)
      values + [time, time_in_seconds]
    end

    def timezone
      ENV['TZ']
    end

    def fmt_time(time)
      time ? Time.at(time).strftime("%H:%M:%S") : "--"
    end

    def race_start_time
      @_start_time ||= Time.at((ChiScore::Repository.fetch_race_start || 0).to_i)
    end

    def finish_checkpoint
      @_finish_checkpoint ||= ChiScore::Checkpoints.find(6)
    end
  end
end
