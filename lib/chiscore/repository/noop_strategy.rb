module ChiScore
  class NoopRepositoryStrategy
    def self.check_in!(*args); end
    def self.active_for(*args); end
    def self.checkins_for(*args); end
    def self.checkouts_for(*args); end
    def self.time_for(*args); end
    def self.check_out!(*args); end
  end
end
