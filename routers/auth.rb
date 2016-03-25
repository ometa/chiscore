module Routers
  class Auth < Router
    ADMIN_KEY = '3E3928ED-1E96-4011-A31A-4DF24BE003EB'

    get("/") { _erb(:"auth/landing") }
    get("/sign_in") { _erb(:"auth/sign_in") }

    post("/login") do
      if ChiScore::Auth.login_auth(params[:login], params[:password])
        login = ChiScore::Logins.find_by_username(params[:login])

        if login.admin?
          session['admin'] = ADMIN_KEY
          redirect "/admin"
        else
          session['checkpoint-id'] = login.checkpoints.id
          redirect "/"
        end
      else
        redirect "/auth"
      end
    end

    get "/logout" do
      session.clear
      redirect "/auth"
    end
  end
end
