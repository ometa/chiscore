require 'forwardable'
require 'chiscore/repository/redis_strategy'

module ChiScore
  class Repository

    StrategyNotSet = Class.new(StandardError)

    class << self
      extend Forwardable

      def_delegators :strategy,
        :check_in!, :check_out!,
        :active_for, :checkins_for,
        :checkouts_for, :time_for, :lock,
        :save_race_start, :fetch_race_start,
        :team_checkin, :team_checkout,
        :flag!, :find_flags, :destroy_checkin!, :team_checkins,
        :team_checkouts

      def set_strategy(strategy)
        @_strategy = strategy
      end

      def strategy
        raise StrategyNotSet if @_strategy.nil?
        @_strategy
      end
    end
  end
end
