require 'rack/test'
require 'spec_helper'
require 'routers/api/checkins'
require 'chiscore/auth'
require 'chiscore/teams'
require 'chiscore/checkpoints'
require 'chiscore/checkins'
require 'chiscore/repository/noop_strategy'
require 'routers/auth'
require 'routers/router'

describe Routers::Api::Checkins do
  include Rack::Test::Methods

  let(:app) { Routers::Api::Checkins }
  let(:checkpoint) { ChiScore::Checkpoint.new(1000, "Barname") }
  let(:team) { ChiScore::Team.new(:id => "team-id", :name => "Dynasty") }

  before {
    allow(ChiScore::Auth).to receive(:login_auth) { true }
    allow(ChiScore::Checkpoints).to receive(:find) { checkpoint }
    allow(ChiScore::Teams).to receive(:find) { team }
    allow(ChiScore::Auth).to receive(:admin_key) { "the-admin-key" }
  }

  context "#set_checkpoint" do
    before { allow(ChiScore::Checkins).to receive(:times_for) }
    it "checks the session for the checkpoint when checkpoint" do
      expect(ChiScore::Checkpoints).to receive(:find).with("9999")

      get "/",
        {"checkpoint" => "8888"},
        'rack.session' => {'checkpoint-id' => "9999" }
    end

    it "checks the params for the checkpoint when admin" do
      allow_any_instance_of(app).to receive(:admin?) { true }

      expect(ChiScore::Checkpoints).to receive(:find).with("8888")

      get "/",
        {"checkpoint" => "8888"},
        'rack.session' => {'checkpoint-id' => "9999" }
    end
  end

  it "gets the checkins for checkpoint" do
    times = { 'team-one' => 45, 'team-two' => 33 }
    allow(ChiScore::Checkins).to receive(:times_for).with(checkpoint) { times }

    get "/"

    expect(last_response.status).to eq(200)
    expect(last_response.body).to eq(times.to_json)
  end

  it "posts the checkins for checkpoint" do
    times = { 'team-one' => 45, 'team-two' => 33 }
    allow(ChiScore::Checkins).to receive(:times_for).with(checkpoint) { times }

    post "/",
         {"checkpoint" => "1000"}

    expect(last_response.status).to eq(200)
    expect(last_response.body).to eq(times.to_json)
  end

  it "creates a checkin for checkpoint" do
    expect(ChiScore::Checkins).to receive(:checkin).with(checkpoint, team)
    post "/checkin", 'team_id' => "team-id"
    expect(last_response.body).to eq({
      :success => true,
      :team => { :id => "team-id", :name => "Dynasty" },
      :time => 1500
    }.to_json)
  end

  it "creates a checkin/checkout for the finish line" do
    finish_line_checkpoint = ChiScore::Checkpoint.new(1337, "Finish Line", "endpoint")
    allow(ChiScore::Checkpoints).to receive(:find) { finish_line_checkpoint }
    expect(ChiScore::Checkins).to receive(:checkin).with(finish_line_checkpoint, team)

    post "/checkin", 'team_id' => "team-id"
  end

  it "returns an error and gives the location if the team is locked" do
    allow(ChiScore::Checkins).to receive(:checkin).and_raise(ChiScore::Checkins::LockedCheckinAttempt)
    allow(ChiScore::Checkins).to receive(:active).and_return(["team-id"])
    allow(ChiScore::Repository).to receive(:time_for).and_return("time-remaining")

    post "/checkin", 'team_id' => "team-id"

    expect(last_response.body).to eq({
      :success => false,
      :checkpoint => {:id => "1", :name => "The Bottom Lounge"},
      :time => "time-remaining"
    }.to_json)
  end

  it "creates a checkout for checkpoint" do
    expect(ChiScore::Checkins).to receive(:checkout).with(checkpoint, team, false)
    post "/checkout", 'team_id' => "team-id"
    expect(last_response.body).to eq({
      :success => true,
      :team => { :id => "team-id", :name => "Dynasty" }
    }.to_json)
  end

  it "returns an error if the checkout is too early" do
    allow(ChiScore::Checkins).to receive(:checkout).and_raise(ChiScore::Checkins::EarlyCheckout)
    post "/checkout", 'team_id' => "team-id"
    expect(last_response.body).to eq({ :success => false }.to_json)
  end

  it "does not return an error if the checkout is too early and current user is admin" do
    expect(ChiScore::Checkins).to receive(:checkout).with(checkpoint, team, true)

    allow_any_instance_of(app).to receive(:admin?) { true }

    post "/checkout", {'team_id' => "team-id"}

    expect(last_response.body).to eq({
      :success => true,
      :team => { :id => "team-id", :name => "Dynasty" }
    }.to_json)
  end

  it "destroys a checkin if admin" do
    allow_any_instance_of(app).to receive(:admin?) { true }
    post "/destroy", { 'team_id' => "team-id", 'checkpoint' => "1000" }

    expect(last_response.body).to eq({
      :destroyed => true,
      :team => { :id => "team-id", :name => "Dynasty" }
    }.to_json)
  end

  it "does not destory a checkin if not admin" do
    post "/destroy", { 'team_id' => "team-id" }

    expect(last_response.body).to eq({ :destroyed => false }.to_json)
  end

  it "gets all the checkins/checkouts for checkpoint" do

    in_time, out_time = Time.now - 25 * 60, Time.now

    checkins = {
      'team-one' => [in_time, out_time],
      'team-two' => [in_time, out_time]
    }

    allow(Routers::Router).to receive_messages(:require_auth! => checkins)

    expect(ChiScore::Checkins).to receive(:all_for).with(checkpoint) { checkins }

    get "/all"

    expect(last_response.body).to eq(checkins.to_json)
  end
end
