require 'chiscore/checkpoints'
require 'digest'

module ChiScore
  class Login
    attr_accessor :username, :password, :id

    def initialize(id, username, password, access)
      @id = 'login_' + id.to_s
      @username, @access = username, access
      @password = Digest::SHA256.digest(password)
    end

    def auth?(password)
      Digest::SHA256.digest(password) == @password
    end

    def admin?
      @access == 0
    end

    def checkpoints
      if admin?
        ChiScore::Checkpoints._collection
      else
        ChiScore::Checkpoints.find(@access)
      end
    end
  end

  class Logins
    extend Support::StaticCollection

    def self.find_by_username(username)
      self.all.find { |login| login.username == username }
    end
  end
end
