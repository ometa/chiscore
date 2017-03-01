require 'rack/test'
require 'spec_helper'
require 'chiscore/repository'
require 'routers/checkpoint'
require 'chiscore/repository/dev_strategy'

describe Routers::Checkpoint do
  include Rack::Test::Methods

  let(:browser) { Rack::Test::Session.new(Rack::MockSession.new(app)) }
  let(:admin_key) { 'the-admin-key' }
  let(:checkpoint) { ChiScore::Checkpoint.new(2, "name") }

  before(:each) { 
    ChiScore::Repository.set_strategy(ChiScore::DevStrategy) 
    allow(ChiScore::Auth).to receive(:admin_key) { admin_key }
  }

  let(:app) { Routers::Checkpoint.new }

  it "doesn't redirect an admin" do
    browser.get "/admin", {}, 'rack.session' => { "admin" => admin_key }
    expect(browser.last_response.status).not_to eq 302
  end

  it "doesn't redirect a checkpoint login user for 'all'" do
    allow(ChiScore::Checkpoints).to receive(:find) {  checkpoint }
    allow(ChiScore::Checkins).to receive(:all_for) { [] }

    browser.get "/all", {}, 'rack.session' => { "checkpoint-id" => 2 }
    expect(browser.last_response.status).not_to eq 302
  end

  it "doesn't redirect a checkpoint login user for root" do
    allow(ChiScore::Checkpoints).to receive(:find) {  checkpoint }
    browser.get "/", {}, 'rack.session' => { "checkpoint-id" => 2 }
    expect(browser.last_response.status).not_to eq 302
  end

  it "redirects non-logged in user to auth from root" do
    browser.get "/"
    expect(browser.last_response.status).to eq 302
  end

  it "redirects a user if not admin" do
    allow(ChiScore::Checkins).to receive(:all_for) { [] }
    browser.get "/all"
    expect(browser.last_response.status).to eq 302
  end

  it "redirects a user to admin page if admin" do
    browser.get "/all", {}, 'rack.session' => { "admin" => admin_key }
    expect(browser.last_response.status).to eq 302
  end

end
