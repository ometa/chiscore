require 'chiscore/logins'

module ChiScore
  module Auth
    def self.login_auth(login, password)
      login = ChiScore::Logins.find_by_username(login)
      login && login.auth?(password)
    end

    def self.secret_key
      ENV['SECRET_KEY'] || File.read("config/secret_key")
    end

    def self.admin_key
      ENV['ADMIN_KEY'] || File.read("config/admin_key")
    end
  end
end
