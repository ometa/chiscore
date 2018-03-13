module ChiScore
  class NoopRepositoryStrategy
    def self.check_in!(*); end
    def self.active_for(*); end
    def self.checkins_for(*); end
    def self.checkouts_for(*); end
    def self.time_for(*); end
    def self.check_out!(*); end
  end
end
