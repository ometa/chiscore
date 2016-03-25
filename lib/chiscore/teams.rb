require 'chiscore/support/static_collection'

module ChiScore
  class Team
    attr_accessor :id, :name, :route, :checkins, :checkouts

    def initialize(attrs = {})
      self.id = attrs[:id]
      self.name = attrs[:name]
      self.route = attrs[:route]
      self.checkins = []
      self.checkouts = []
    end

    def ==(other)
      self.name == other.name && self.id == other.id && self.route == other.route
    end

    def <=>(other)
      if other.visit_count == self.visit_count
        return 0 if checkins.count == 0
        self.last_checkin <=> other.last_checkin
      else
        other.visit_count <=> self.visit_count
      end
    end

    def last_checkin
      if at_checkpoint?
        ChiScore::Checkins.time_for(last_checkpoint, self)
      else
        ChiScore::Checkins.checkout_for(last_checkpoint, self)
      end
    end

    def last_checkpoint
      @last_checkpoint ||= ChiScore::Checkpoints.find(last_checkpoint_id)
    end

    def last_checkpoint_id
      at_checkpoint? ? checkins.last : checkouts.last
    end

    def at_checkpoint?
      @__is_at ||= checkins.count > checkouts.count
    end

    def visits
      [ checkouts, checkins ]
    end

    def visit_count
      visits.map(&:count)
    end
  end

  class Teams
    extend Support::StaticCollection

    def self.for_route(route)
      all.select { |team| team.route == route.id }
    end
  end
end
