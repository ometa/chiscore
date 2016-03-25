require 'sinatra'
require 'json'
require 'routers/helpers/auth_helper'
require 'routers/helpers/leaderboard_helper'

module Routers
  class Router < Sinatra::Base
    include AuthHelper
    include LeaderboardHelper

    attr_reader :checkpoint

    set :show_exceptions, false if ENV['RACK_ENV'] == "test"
    set :views, Dir.pwd + "/templates"
    set :public_folder, Dir.pwd + "/static"

    def _erb(name, locals = {})
      erb(name, :layout => :layout, :locals => locals)
    end

    def _partial(name, locals = {})
      erb(name, :layout => false, :locals => locals)
    end

    def _scoreboard(locals = {}, include_checkouts=false)
      locals[:include_checkouts] = include_checkouts
      _partial(:_scoreboard, locals)
    end

    def redirect_to_login
      redirect "/auth"
    end
  end
end
