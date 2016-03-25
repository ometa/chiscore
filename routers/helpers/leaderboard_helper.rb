module LeaderboardHelper

  def team_checkpoint_status(checkpoint, team, is_public)
    CheckinStatus.new(checkpoint, team, is_public).evaluate
  end

  CheckinStatus = Struct.new(:checkpoint, :team, :is_public) do
    def evaluate
      find_time == 0 ? "--" : get_standings
    end

    def get_standings
      is_public ? get_status : get_time
    end

    def get_status
      checked_out?  ? checked_out_status : checked_in_status
    end

    def checked_out_status
      html_output("red", get_time)
    end

    def checked_in_status
      html_output("green", get_time)
    end

    def find_checkout_time
      @checkout_time ||= ChiScore::Checkins.checkout_for(checkpoint, team)
    end

    def checked_out?
      find_checkout_time > 0
    end

    def find_time
      @time ||= ChiScore::Checkins.time_for(checkpoint, team)
    end

    def get_time
      Time.at(find_time.to_i).strftime("%I:%M %P")
    end

    def html_output(color, text)
      "<p style='color:#{color};'>#{text}</p>"
    end
  end
end
