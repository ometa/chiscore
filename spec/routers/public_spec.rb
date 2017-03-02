require 'rack/test'
require 'spec_helper'
require 'routers/public'
require 'lib/chiscore/leaderboard'

describe Routers::Public do
  include Rack::Test::Methods

  let(:app) { Routers::Public }

  before(:each) { allow_any_instance_of(app).to receive(:update_scores) }

  it "redirects if admin" do
    allow_any_instance_of(app).to receive(:admin?) { true }
    get "/"
    expect(last_response).to be_redirect
    expect(last_response.location).to include("/admin")
  end

  it "redirects if route doesn't exist" do
    allow(ChiScore::Routes).to receive(:find).and_raise(KeyError)
    get "/error"
    expect(last_response).to be_redirect
    expect(last_response.location).to eq("http://example.org/public")
  end

  it "redirects to leaderboard if 'all' is selected" do
    get "/all"
    expect(last_response).to be_redirect
    expect(last_response.location).to eq("http://example.org/public")
  end
end
